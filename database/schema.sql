-- EduWay database schema (PostgreSQL). Safe to run many times.

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    salt BYTEA NOT NULL,
    password_hash BYTEA NOT NULL
);

CREATE TABLE IF NOT EXISTS subjects (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS topics (
    id SERIAL PRIMARY KEY,
    subject_id INTEGER NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    pos INTEGER NOT NULL,                 -- topic number inside the subject
    name TEXT NOT NULL,
    UNIQUE (subject_id, pos)
);

CREATE TABLE IF NOT EXISTS questions (
    id SERIAL PRIMARY KEY,
    topic_id INTEGER NOT NULL REFERENCES topics(id) ON DELETE CASCADE,
    pos INTEGER NOT NULL,                 -- question number inside the topic
    text TEXT NOT NULL,
    options TEXT[] NOT NULL,              -- answer options in order
    correct_index SMALLINT CHECK (correct_index BETWEEN 0 AND 3),  -- 0 = first option
    UNIQUE (topic_id, pos)
);

-- one row per drawn ticket
CREATE TABLE IF NOT EXISTS tickets (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    topic_id INTEGER NOT NULL REFERENCES topics(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    finished_at TIMESTAMPTZ
);

-- questions of a ticket; this table is also the history used to avoid repeats
CREATE TABLE IF NOT EXISTS ticket_questions (
    ticket_id INTEGER NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
    question_id INTEGER NOT NULL REFERENCES questions(id),
    pos INTEGER NOT NULL,                 -- order of the question in the ticket
    chosen_index SMALLINT CHECK (chosen_index BETWEEN 0 AND 3),  -- user's answer
    PRIMARY KEY (ticket_id, question_id)
);

CREATE INDEX IF NOT EXISTS idx_tickets_user ON tickets (user_id, created_at DESC);