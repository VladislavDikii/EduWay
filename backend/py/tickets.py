import os
import random

import psycopg
from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel, Field

# same environment variables as in main.py
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "eduway")
DB_USER = os.getenv("DB_USER", "eduway")
DB_PASSWORD = os.getenv("DB_PASSWORD", "eduway")

router = APIRouter()


def get_db():
    return psycopg.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
    )


def get_user_id(conn, username: str) -> int:
    row = conn.execute(
        "SELECT id FROM users WHERE username = %s", (username.strip(),)
    ).fetchone()
    if row is None:
        raise HTTPException(status_code=404, detail="user not found")
    return row[0]


class DrawRequest(BaseModel):
    username: str = Field(min_length=1, max_length=50)
    topic_id: int
    count: int = Field(default=5, ge=1, le=50)
    # True  -> questions the user has not seen yet come first; when they run
    #          out, the ones asked longest ago are used (a new round)
    # False -> plain random, repeats allowed
    no_repeats: bool = True


class AnswerIn(BaseModel):
    question_id: int
    chosen_index: int | None = Field(default=None, ge=0, le=3)  # None = skipped


class SubmitRequest(BaseModel):
    username: str = Field(min_length=1, max_length=50)
    answers: list[AnswerIn]


# ---------- subjects and topics (so the app does not have to hardcode them) ----------

@router.get("/api/subjects")
def list_subjects():
    with get_db() as conn:
        rows = conn.execute(
            "SELECT s.id, s.name, COUNT(q.id) "
            "FROM subjects s "
            "LEFT JOIN topics t ON t.subject_id = s.id "
            "LEFT JOIN questions q ON q.topic_id = t.id "
            "GROUP BY s.id ORDER BY s.id"
        ).fetchall()
    return [{"id": r[0], "name": r[1], "questions": r[2]} for r in rows]


@router.get("/api/subjects/{subject_id}/topics")
def list_topics(subject_id: int):
    with get_db() as conn:
        if conn.execute(
            "SELECT 1 FROM subjects WHERE id = %s", (subject_id,)
        ).fetchone() is None:
            raise HTTPException(status_code=404, detail="subject not found")
        rows = conn.execute(
            "SELECT t.id, t.pos, t.name, COUNT(q.id) "
            "FROM topics t LEFT JOIN questions q ON q.topic_id = t.id "
            "WHERE t.subject_id = %s GROUP BY t.id ORDER BY t.pos",
            (subject_id,),
        ).fetchall()
    return [{"id": r[0], "pos": r[1], "name": r[2], "questions": r[3]} for r in rows]


# ---------- tickets ----------

@router.post("/api/tickets/draw", status_code=201)
def draw_ticket(data: DrawRequest):
    """Create a ticket: random questions of a topic for a user."""
    with get_db() as conn:
        user_id = get_user_id(conn, data.username)

        if conn.execute(
            "SELECT 1 FROM topics WHERE id = %s", (data.topic_id,)
        ).fetchone() is None:
            raise HTTPException(status_code=404, detail="topic not found")

        # every question of the topic + when this user last got it (NULL = never)
        rows = conn.execute(
            "SELECT q.id, q.pos, q.text, q.options, "
            "  (SELECT MAX(t.created_at) FROM ticket_questions tq "
            "   JOIN tickets t ON t.id = tq.ticket_id "
            "   WHERE tq.question_id = q.id AND t.user_id = %s) AS last_seen "
            "FROM questions q WHERE q.topic_id = %s",
            (user_id, data.topic_id),
        ).fetchall()
        if not rows:
            raise HTTPException(status_code=404, detail="no questions in this topic")

        count = min(data.count, len(rows))
        new_round = False
        left_in_round = None

        if data.no_repeats:
            fresh = [r for r in rows if r[4] is None]
            seen = sorted((r for r in rows if r[4] is not None), key=lambda r: r[4])
            random.shuffle(fresh)
            picked = fresh[:count]
            if len(picked) < count:
                # not enough fresh questions: add the ones asked longest ago
                new_round = True
                picked += seen[: count - len(picked)]
            left_in_round = max(len(fresh) - count, 0)
        else:
            picked = random.sample(rows, count)

        random.shuffle(picked)

        ticket_id, created_at = conn.execute(
            "INSERT INTO tickets (user_id, topic_id) VALUES (%s, %s) "
            "RETURNING id, created_at",
            (user_id, data.topic_id),
        ).fetchone()
        for pos, r in enumerate(picked, start=1):
            conn.execute(
                "INSERT INTO ticket_questions (ticket_id, question_id, pos) "
                "VALUES (%s, %s, %s)",
                (ticket_id, r[0], pos),
            )

    # correct_index is NOT sent: the app gets it only after the answers are submitted
    return {
        "ticket_id": ticket_id,
        "topic_id": data.topic_id,
        "created_at": created_at.isoformat(),
        "new_round": new_round,
        "left_in_round": left_in_round,
        "questions": [
            {"id": r[0], "pos": pos, "text": r[2], "options": r[3]}
            for pos, r in enumerate(picked, start=1)
        ],
    }


@router.post("/api/tickets/{ticket_id}/submit")
def submit_ticket(ticket_id: int, data: SubmitRequest):
    """Save the user's answers, finish the ticket and return the result."""
    with get_db() as conn:
        user_id = get_user_id(conn, data.username)

        ticket = conn.execute(
            "SELECT user_id, finished_at FROM tickets WHERE id = %s FOR UPDATE",
            (ticket_id,),
        ).fetchone()
        if ticket is None or ticket[0] != user_id:
            raise HTTPException(status_code=404, detail="ticket not found")
        if ticket[1] is not None:
            raise HTTPException(status_code=409, detail="ticket already finished")

        questions = conn.execute(
            "SELECT tq.question_id, q.correct_index "
            "FROM ticket_questions tq JOIN questions q ON q.id = tq.question_id "
            "WHERE tq.ticket_id = %s ORDER BY tq.pos",
            (ticket_id,),
        ).fetchall()
        in_ticket = {qid for qid, _ in questions}

        chosen = {}
        for a in data.answers:
            if a.question_id not in in_ticket:
                raise HTTPException(
                    status_code=422, detail="question is not in this ticket"
                )
            chosen[a.question_id] = a.chosen_index

        results = []
        score = 0
        for qid, correct in questions:
            ch = chosen.get(qid)
            ok = ch is not None and correct is not None and ch == correct
            score += 1 if ok else 0
            conn.execute(
                "UPDATE ticket_questions SET chosen_index = %s "
                "WHERE ticket_id = %s AND question_id = %s",
                (ch, ticket_id, qid),
            )
            results.append(
                {
                    "question_id": qid,
                    "chosen_index": ch,
                    "correct_index": correct,
                    "is_correct": ok,
                }
            )

        conn.execute(
            "UPDATE tickets SET finished_at = now() WHERE id = %s", (ticket_id,)
        )

    return {
        "ticket_id": ticket_id,
        "score": score,
        "total": len(questions),
        "results": results,
    }


@router.get("/api/tickets")
def list_tickets(username: str, limit: int = Query(default=20, ge=1, le=100)):
    """Ticket history of a user, newest first."""
    with get_db() as conn:
        user_id = get_user_id(conn, username)
        rows = conn.execute(
            "SELECT t.id, t.topic_id, tp.name, t.created_at, t.finished_at, "
            "  COUNT(tq.question_id), "
            "  COUNT(*) FILTER (WHERE tq.chosen_index = q.correct_index) "
            "FROM tickets t "
            "JOIN topics tp ON tp.id = t.topic_id "
            "JOIN ticket_questions tq ON tq.ticket_id = t.id "
            "JOIN questions q ON q.id = tq.question_id "
            "WHERE t.user_id = %s "
            "GROUP BY t.id, tp.name "
            "ORDER BY t.created_at DESC LIMIT %s",
            (user_id, limit),
        ).fetchall()
    return [
        {
            "ticket_id": r[0],
            "topic_id": r[1],
            "topic": r[2],
            "created_at": r[3].isoformat(),
            "finished_at": r[4].isoformat() if r[4] else None,
            "total": r[5],
            "score": r[6] if r[4] else None,
        }
        for r in rows
    ]