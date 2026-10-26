from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/")
def index():
    return "Hello from Flask\n"


@app.get("/health")
def health():
    return jsonify(status="ok")
