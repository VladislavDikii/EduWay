import random
import sqlite3
 
from fastapi import APIRouter, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
 
DB_PATH = "eduway.db"
 
 
def get_db():
    return sqlite3.connect(DB_PATH)
 
 
def init_db():
    conn = get_db()
    conn.execute(
        """CREATE TABLE IF NOT EXISTS tickets (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            number INTEGER NOT NULL UNIQUE,
            title TEXT NOT NULL,
            body TEXT NOT NULL DEFAULT ''
        )"""
    )
    # история выпавших билетов: чтобы не повторяться для одного пользователя
    conn.execute(
        """CREATE TABLE IF NOT EXISTS ticket_draws (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            ticket_id INTEGER NOT NULL REFERENCES tickets(id),
            drawn_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )"""
    )
    conn.commit()
    conn.close()
 
 
init_db()
router = APIRouter()
 
 
 
class TicketIn(BaseModel):
    number: int = Field(ge=1)
    title: str = Field(min_length=1, max_length=200)
    body: str = Field(default="", max_length=5000)
 
 
class DrawRequest(BaseModel):
    username: str = Field(min_length=1, max_length=50)
    count: int = Field(default=1, ge=1, le=50)
    # True  -> no repeats until the user has drawn every ticket (then a new round)
    # False -> plain random, repeats allowed
    no_repeats: bool = True
 
 
def ticket_to_dict(row) -> dict:
    return {"id": row[0], "number": row[1], "title": row[2], "body": row[3]}
 
 
@router.post("/api/tickets", status_code=201)
def add_ticket(data: TicketIn):
    conn = get_db()
    try:
        cur = conn.execute(
            "INSERT INTO tickets (number, title, body) VALUES (?, ?, ?)",
            (data.number, data.title.strip(), data.body),
        )
        conn.commit()
        return {"id": cur.lastrowid, **data.model_dump()}
    except sqlite3.IntegrityError:
        raise HTTPException(status_code=409, detail="ticket number already exists")
    finally:
        conn.close()
 
 
@router.get("/api/tickets")
def list_tickets():
    conn = get_db()
    rows = conn.execute(
        "SELECT id, number, title, body FROM tickets ORDER BY number"
    ).fetchall()
    conn.close()
    return [ticket_to_dict(r) for r in rows]
 
 
@router.post("/api/tickets/draw")
def draw_tickets(data: DrawRequest):
    """Random ticket(s) for a user."""
    username = data.username.strip()
    conn = get_db()
    try:
        user_id = username
 
        tickets = conn.execute(
            "SELECT id, number, title, body FROM tickets"
        ).fetchall()
        if not tickets:
            raise HTTPException(status_code=404, detail="no tickets yet")
 
        new_round = False
        if data.no_repeats:
            drawn = {
                r[0]
                for r in conn.execute(
                    "SELECT ticket_id FROM ticket_draws WHERE username = ?",
                    (user_id,),
                )
            }
            pool = [t for t in tickets if t[0] not in drawn]
            if len(pool) < data.count:
                # not enough fresh tickets: start a new round
                conn.execute("DELETE FROM ticket_draws WHERE username = ?", (user_id,))
                pool = tickets
                new_round = True
            picked = random.sample(pool, min(data.count, len(pool)))
        else:
            pool = tickets
            picked = random.sample(pool, min(data.count, len(pool)))
 
        conn.executemany(
            "INSERT INTO ticket_draws (username, ticket_id) VALUES (?, ?)",
            [(user_id, t[0]) for t in picked],
        )
        conn.commit()
 
        return {
            "tickets": [ticket_to_dict(t) for t in picked],
            "new_round": new_round,
            "left_in_round": (len(pool) - len(picked)) if data.no_repeats else None,
        }
    finally:
        conn.close()
 
 
@router.post("/api/tickets/reset")
def reset_draws(username: str):
    """Forget the draw history of a user (start a new round manually)."""
    conn = get_db()
    try:
        conn.execute("DELETE FROM ticket_draws WHERE username = ?", (username.strip(),))
        conn.commit()
        return {"message": "reset"}
    finally:
        conn.close()
 
 
# автономный запуск
app = FastAPI()
app.add_middleware(
    CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"]
)
app.include_router(router)
 