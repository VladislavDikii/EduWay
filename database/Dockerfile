FROM python:3.13-slim
WORKDIR /app
RUN pip install --no-cache-dir python-docx "psycopg[binary]"
COPY . .
CMD ["python", "import_questions.py"]