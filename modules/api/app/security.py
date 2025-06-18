import os
from functools import wraps
from flask import request, jsonify

API_TOKEN = os.getenv("API_TOKEN", "changeme")

def verify_token(f):
    @wraps(f)
    def wrapper(*args, **kwargs):
        auth = request.headers.get("Authorization", "")
        if not auth.startswith("Bearer ") or auth.split()[1] != API_TOKEN:
            return jsonify({"error": "Unauthorized"}), 401
        return f(*args, **kwargs)
    return wrapper
