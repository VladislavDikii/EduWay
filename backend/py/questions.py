from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from tickets import get_db

router = APIRouter()

COLUMNS = "q.id, q.topic_id, t.name, t.pos, q.pos, q.text, q.options, q.correct_index"


class QuestionOut(BaseModel):
    id: int
    topic_id: int
    topic: str
    topic_pos: int
    pos: int
    text: str
    options: list[str]
    correct_index: int | None


def to_dict(r) -> QuestionOut:
    return QuestionOut(
        id=r[0],
        topic_id=r[1],
        topic=r[2],
        topic_pos=r[3],
        pos=r[4],
        text=r[5],
        options=r[6],
        correct_index=r[7],  # index of the right option, 0 = first
    )


@router.get("/api/subjects/{subject_id}/questions", response_model=list[QuestionOut])
def subject_questions(subject_id: int):
    """All questions of a subject with answers, ordered by topic and number."""
    with get_db() as conn:
        if conn.execute(
            "SELECT 1 FROM subjects WHERE id = %s", (subject_id,)
        ).fetchone() is None:
            raise HTTPException(status_code=404, detail="subject not found")
        rows = conn.execute(
            f"SELECT {COLUMNS} FROM questions q JOIN topics t ON t.id = q.topic_id "
            "WHERE t.subject_id = %s ORDER BY t.pos, q.pos",
            (subject_id,),
        ).fetchall()
    return [to_dict(r) for r in rows]


@router.get("/api/topics/{topic_id}/questions", response_model=list[QuestionOut])
def topic_questions(topic_id: int):
    """Questions of one topic with answers."""
    with get_db() as conn:
        if conn.execute(
            "SELECT 1 FROM topics WHERE id = %s", (topic_id,)
        ).fetchone() is None:
            raise HTTPException(status_code=404, detail="topic not found")
        rows = conn.execute(
            f"SELECT {COLUMNS} FROM questions q JOIN topics t ON t.id = q.topic_id "
            "WHERE q.topic_id = %s ORDER BY q.pos",
            (topic_id,),
        ).fetchall()
    return [to_dict(r) for r in rows]


@router.get("/api/questions/{question_id}/answer")
def question_answer(question_id: int):
    """Correct answer of one question (for the self-check button, SCRUM-22)."""
    with get_db() as conn:
        row = conn.execute(
            "SELECT correct_index FROM questions WHERE id = %s", (question_id,)
        ).fetchone()
    if row is None:
        raise HTTPException(status_code=404, detail="question not found")
    return {"question_id": question_id, "correct_index": row[0]}
