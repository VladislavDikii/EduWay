import hashlib
import hmac
import os
import sqlite3

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

DB_PATH = "eduway.db"

app = FastAPI()
# allow requests from the Flutter app (needed for Flutter web)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


def get_db():
    return sqlite3.connect(DB_PATH)


def init_db():
    conn = get_db()
    conn.execute(
        """CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            salt BLOB NOT NULL,
            password_hash BLOB NOT NULL
        )"""
    )
    conn.commit()
    conn.close()


init_db()


def hash_password(password: str, salt: bytes) -> bytes:
    return hashlib.pbkdf2_hmac("sha256", password.encode(), salt, 200_000)


class Credentials(BaseModel):
    username: str = Field(min_length=1, max_length=50)
    password: str = Field(min_length=6, max_length=128)


@app.post("/api/register", status_code=201)
def register(data: Credentials):
    username = data.username.strip()
    if not username:
        raise HTTPException(status_code=422, detail="empty username")

    salt = os.urandom(16)
    password_hash = hash_password(data.password, salt)

    conn = get_db()
    try:
        conn.execute(
            "INSERT INTO users (username, salt, password_hash) VALUES (?, ?, ?)",
            (username, salt, password_hash),
        )
        conn.commit()
    except sqlite3.IntegrityError:
        raise HTTPException(status_code=409, detail="username already taken")
    finally:
        conn.close()

    return {"message": "registered", "username": username}


@app.post("/api/login")
def login(data: Credentials):
    username = data.username.strip()

    conn = get_db()
    row = conn.execute(
        "SELECT salt, password_hash FROM users WHERE username = ?", (username,)
    ).fetchone()
    conn.close()

    if row is None or not hmac.compare_digest(
        hash_password(data.password, row[0]), row[1]
    ):
        raise HTTPException(status_code=401, detail="wrong username or password")

    return {"message": "ok", "username": username}