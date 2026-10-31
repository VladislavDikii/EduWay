import hashlib
import hmac
import os
import secrets
import time
from typing import Optional

import psycopg
from fastapi import Depends, FastAPI, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from psycopg import errors
from pydantic import BaseModel, Field

# connection settings come from environment variables
# (defaults are only for local development)
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "eduway")
DB_USER = os.getenv("DB_USER", "eduway")
DB_PASSWORD = os.getenv("DB_PASSWORD", "eduway")

app = FastAPI()
# allow requests from the Flutter app (needed for Flutter web)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


def get_db():
    return psycopg.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
    )


def init_db():
    # the database container may start slower than the backend, so retry
    for attempt in range(10):
        try:
            with get_db() as conn:
                conn.execute(
                    """CREATE TABLE IF NOT EXISTS users (
                        id SERIAL PRIMARY KEY,
                        username TEXT NOT NULL UNIQUE,
                        salt BYTEA NOT NULL,
                        password_hash BYTEA NOT NULL
                    )"""
                )
                # сессии: один вход = одна строка. Выход = удаление строки.
                conn.execute(
                    """CREATE TABLE IF NOT EXISTS sessions (
                        token_hash TEXT PRIMARY KEY,
                        user_id INTEGER NOT NULL
                            REFERENCES users(id) ON DELETE CASCADE,
                        created_at TIMESTAMPTZ NOT NULL DEFAULT now()
                    )"""
                )
            return
        except psycopg.OperationalError:
            time.sleep(1)
    raise RuntimeError("could not connect to the database")


init_db()


def hash_password(password: str, salt: bytes) -> bytes:
    return hashlib.pbkdf2_hmac("sha256", password.encode(), salt, 200_000)


def hash_token(token: str) -> str:
    # в базе храним только хэш токена, а не сам токен
    return hashlib.sha256(token.encode()).hexdigest()


def get_token(authorization: Optional[str] = Header(default=None)) -> str:
    # ожидаем заголовок:  Authorization: Bearer <token>
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="not authenticated")
    return authorization[len("Bearer "):].strip()


def current_user(token: str = Depends(get_token)) -> dict:
    """Зависимость для защищённых эндпоинтов: без активной сессии -> 401."""
    token_hash = hash_token(token)
    with get_db() as conn:
        row = conn.execute(
            "SELECT u.id, u.username FROM sessions s "
            "JOIN users u ON u.id = s.user_id WHERE s.token_hash = %s",
            (token_hash,),
        ).fetchone()
    if row is None:
        raise HTTPException(status_code=401, detail="not authenticated")
    return {"id": row[0], "username": row[1], "token_hash": token_hash}


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

    try:
        # "with" commits on success and closes the connection at the end
        with get_db() as conn:
            conn.execute(
                "INSERT INTO users (username, salt, password_hash) "
                "VALUES (%s, %s, %s)",
                (username, salt, password_hash),
            )
    except errors.UniqueViolation:
        raise HTTPException(status_code=409, detail="username already taken")

    return {"message": "registered", "username": username}


@app.post("/api/login")
def login(data: Credentials):
    username = data.username.strip()

    with get_db() as conn:
        row = conn.execute(
            "SELECT id, salt, password_hash FROM users WHERE username = %s",
            (username,),
        ).fetchone()

    if row is None or not hmac.compare_digest(
        hash_password(data.password, row[1]), row[2]
    ):
        raise HTTPException(status_code=401, detail="wrong username or password")

    # вход успешен -> создаём сессию и отдаём токен клиенту
    token = secrets.token_urlsafe(32)
    with get_db() as conn:
        conn.execute(
            "INSERT INTO sessions (token_hash, user_id) VALUES (%s, %s)",
            (hash_token(token), row[0]),
        )

    return {"message": "ok", "username": username, "token": token}


@app.post("/api/logout")
def logout(user: dict = Depends(current_user)):
    """Кнопка «Выйти»: завершает сессию (удаляет токен из базы)."""
    with get_db() as conn:
        conn.execute(
            "DELETE FROM sessions WHERE token_hash = %s", (user["token_hash"],)
        )
    return {"message": "logged out"}


@app.get("/api/me")
def me(user: dict = Depends(current_user)):
    """Пример защищённого эндпоинта: после выхода отдаёт 401."""
    return {"username": user["username"]}
 