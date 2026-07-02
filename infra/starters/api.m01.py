"""API demo del curso — estado M01 (config embebida, solo exploración)."""
from __future__ import annotations

import random
import time

import redis
from flask import Flask, jsonify
from psycopg2 import connect

app = Flask(__name__)

DATABASE_URL = "postgres://lab:lab@postgres:5432/lab"
REDIS_URL = "redis://redis:6379/0"
API_PORT = 8081
SERVICE_NAME = "cloudnative-demo-api"
LAB_SLOW_SECONDS = 3.0


@app.get("/health")
def health():
    """Liveness básico: el proceso Flask responde."""
    return jsonify(status="ok", service=SERVICE_NAME)


@app.get("/work")
def work():
    delay = random.uniform(0.05, 0.35)
    time.sleep(delay)

    client = redis.from_url(REDIS_URL)
    hits = client.incr("lab:hits")

    with connect(DATABASE_URL) as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT 1")
            cur.fetchone()

    return jsonify(hits=int(hits), delay_ms=round(delay * 1000, 1))


@app.get("/slow")
def slow():
    time.sleep(LAB_SLOW_SECONDS)
    return jsonify(status="slow", delay_seconds=LAB_SLOW_SECONDS)


@app.get("/fail")
def fail():
    return jsonify(error="simulated failure"), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=API_PORT)
