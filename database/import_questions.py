import os
import re
import sys

import docx

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, "data")

LETTERS = ["а", "б", "в", "г"]  # cyrillic letters, as used in the docx files
LATIN = {"a": 0, "b": 1, "c": 2, "d": 3}  # the answer key uses latin a-d

# subject name, docx file, topic names (None = take the name from the docx)
SUBJECTS = [
    ("Математичний аналіз", "Eduway_Math.docx", None),
    ("Історія України", "EduWay_History.docx", [
        "Київська Русь та її розквіт",
        "Козацька доба та Гетьманщина",
        "Україна в XIX столітті",
        "Українська революція 1917–1921 рр.",
    ]),
]

# DRAFT answer key, one string per topic, in question order.
# a, b, c, d = first, second, third, fourth option. MUST be checked by the authors.
ANSWERS = {
    "Eduway_Math.docx": [
        "c,b,c,a,c,b,b,b,b,a,b",
        "b,b,a,b,a,b,a,b,b,b,c",
        "a,b,b,a,c,a,a,b,b,b,b,b",
        "a,b,b,a,b,b,a,a,b,b,a",
    ],
    "EduWay_History.docx": [
        "c,b,a,b,b,a,b,b",
        "b,c,a,a,b,c,a,c",
        "b,b,a,b,b,b,b,b",
        "b,a,d,b,c,b,b,c",
    ],
}


def split_options(opts, where):
    """'а) x, б) y, в) z, г) w' -> ['x', 'y', 'z', 'w'] (strict)."""
    opts = opts.strip()
    if opts.endswith(")"):
        opts = opts[:-1]  # closing bracket of "(Варіанти: ...)"
    if not opts.startswith("а)"):
        raise ValueError(where + ": options do not start with the first letter")
    positions = [0]
    for letter in LETTERS[1:]:
        p = opts.find(", " + letter + ")", positions[-1] + 2)
        if p == -1:
            raise ValueError(where + ": option marker for letter #%d not found "
                             "(typo or duplicate letter?)" % (len(positions) + 1))
        positions.append(p)
    result = []
    for i, start in enumerate(positions):
        begin = start + 2 if i == 0 else start + 4
        end = positions[i + 1] if i + 1 < len(positions) else len(opts)
        result.append(opts[begin:end].strip())
    return result


def parse_docx(path):
    """Returns a list of topics: {'name': str or None, 'questions': [(text, [4 options])]}."""
    topics = []
    for p in docx.Document(path).paragraphs:
        text = p.text.strip()
        if not text:
            continue
        if text.startswith("="):  # topic header line
            m = re.search(r"Тема\s*\d+\s*:\s*(.+?)\s*=*$", text)
            topics.append({"name": m.group(1) if m else None, "questions": []})
            continue
        if "(Варіанти:" not in text:
            continue
        where = "%s, topic %d, question %d" % (
            os.path.basename(path), len(topics), len(topics[-1]["questions"]) + 1)
        q_text, opts = text.rsplit("(Варіанти:", 1)
        q_text = re.sub(r"^\s*\d+\.\s*", "", q_text).strip()
        topics[-1]["questions"].append((q_text, split_options(opts, where)))
    return topics


def load_all():
    """Parse every file and attach topic names and answers. Fail loudly on problems."""
    loaded = []
    for subject, filename, names in SUBJECTS:
        topics = parse_docx(os.path.join(DATA, filename))
        keys = ANSWERS[filename]
        if len(topics) != len(keys):
            raise ValueError("%s: %d topics but %d answer rows" % (filename, len(topics), len(keys)))
        for i, t in enumerate(topics):
            if names:
                t["name"] = names[i]
            letters = keys[i].split(",")
            if len(letters) != len(t["questions"]):
                raise ValueError("%s, topic %d: %d questions but %d answers"
                                 % (filename, i + 1, len(t["questions"]), len(letters)))
            t["answers"] = [LATIN[x.strip()] for x in letters]
        loaded.append((subject, topics))
    return loaded


def main():
    import psycopg  # imported here so parsing can be tested without a database

    loaded = load_all()
    conn = psycopg.connect(
        host=os.getenv("DB_HOST", "localhost"),
        port=os.getenv("DB_PORT", "5432"),
        dbname=os.getenv("DB_NAME", "eduway"),
        user=os.getenv("DB_USER", "eduway"),
        password=os.getenv("DB_PASSWORD", "eduway"),
    )
    with conn:
        with open(os.path.join(HERE, "schema.sql"), encoding="utf-8") as f:
            conn.execute(f.read())
        total = 0
        for subject, topics in loaded:
            sid = conn.execute(
                "INSERT INTO subjects (name) VALUES (%s) "
                "ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name RETURNING id",
                (subject,)).fetchone()[0]
            for ti, t in enumerate(topics, start=1):
                tid = conn.execute(
                    "INSERT INTO topics (subject_id, pos, name) VALUES (%s, %s, %s) "
                    "ON CONFLICT (subject_id, pos) DO UPDATE SET name = EXCLUDED.name "
                    "RETURNING id", (sid, ti, t["name"])).fetchone()[0]
                for qi, ((text, options), correct) in enumerate(
                        zip(t["questions"], t["answers"]), start=1):
                    conn.execute(
                        "INSERT INTO questions (topic_id, pos, text, options, correct_index) "
                        "VALUES (%s, %s, %s, %s, %s) "
                        "ON CONFLICT (topic_id, pos) DO UPDATE SET "
                        "text = EXCLUDED.text, options = EXCLUDED.options, "
                        "correct_index = EXCLUDED.correct_index",
                        (tid, qi, text, options, correct))
                    total += 1
    conn.close()
    print("done, questions loaded: %d" % total)


if __name__ == "__main__":
    try:
        main()
    except ValueError as e:
        print("ERROR: " + str(e).encode("ascii", "replace").decode("ascii"))
        sys.exit(1)