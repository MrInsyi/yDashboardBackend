from flask import Blueprint, jsonify, request
from mes import run_query
from datetime import date, timedelta

leak_bp = Blueprint("leak_bp", __name__)

@leak_bp.route("/api/leak_defects", methods=["GET"])
def get_leak_defects():
    today = date.today()
    start_date = request.args.get("start", (today - timedelta(days=7)).isoformat())
    end_date = request.args.get("end", today.isoformat())

    if not start_date or not end_date:
        return jsonify({"error": "Missing date range: use ?start=YYYY-MM-DD&end=YYYY-MM-DD"}), 400

    # Load SQL text from file
    with open("queries/leak_defect_query.sql", "r") as f:
        sql = f.read()

    results = run_query(sql, (start_date, end_date))
    return jsonify(results)
