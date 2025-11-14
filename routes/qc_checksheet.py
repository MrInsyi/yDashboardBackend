from flask import Blueprint, jsonify, request
from mes import run_query
from datetime import date, timedelta

qc_checksheet = Blueprint("qc_checksheet", __name__)

@qc_checksheet.route("/api/qc_cs", methods=["GET"])
def get_qc_checksheet():
    today = date.today()
# 🧭 read month param or default to current month
    month = request.args.get("month") or date.today().strftime("%Y-%m")

    # Load SQL text from file
    with open("queries/qc_checksheet.sql", "r") as f:
        sql = f.read()

    results = run_query(sql, (month,))
    return jsonify(results)


