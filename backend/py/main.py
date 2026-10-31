import hashlib
import hmac
import os
import time

import psycopg
from fastapi import FastAPI, HTTPException
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
            return
        except psycopg.OperationalError:
            time.sleep(1)
    raise RuntimeError("could not connect to the database")


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
            "SELECT salt, password_hash FROM users WHERE username = %s",
            (username,),
        ).fetchone()

    if row is None or not hmac.compare_digest(
        hash_password(data.password, row[0]), row[1]
    ):
        raise HTTPException(status_code=401, detail="wrong username or password")

    return {"message": "ok", "username": username}