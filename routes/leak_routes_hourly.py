from flask import Blueprint, jsonify, request
from mes import run_query
from datetime import datetime, date

leak_h = Blueprint("leak_hourly", __name__)

@leak_h.route("/api/leak_hourly", methods=["GET"])
def get_leak_hourly():
    station_id = request.args.get("station_id", default=10, type=int)
    target_date = request.args.get("date")

    # ✅ default to today's date if none supplied
    if not target_date:
        target_date = date.today().isoformat()  # or datetime.now().date().isoformat()

    with open("queries/leak_defect_hourly.sql", "r") as f:
        sql = f.read()

    data = run_query(sql, {"station_id": station_id, "target_date": target_date})
    return jsonify(data)

@leak_h.route("/api/leak_hourly_demo", methods=["GET"])
def get_leak_hourly_demo():
    # optional: simulate dynamic parameters
    station_id = request.args.get("station_id", "10")
    date = request.args.get("date", "2025-11-19")

    # fake hourly data for demo
    demo_data = [
        {"hour_label": "08", "total_defect": 3, "total_output": 98, "yield_rate": 96.9, "fpy_rate": 94.5},
        {"hour_label": "09", "total_defect": 5, "total_output": 110, "yield_rate": 95.5, "fpy_rate": 92.0},
        {"hour_label": "10", "total_defect": 2, "total_output": 115, "yield_rate": 98.3, "fpy_rate": 96.7},
        {"hour_label": "11", "total_defect": 6, "total_output": 120, "yield_rate": 94.8, "fpy_rate": 91.0},
        {"hour_label": "12", "total_defect": 4, "total_output": 105, "yield_rate": 96.2, "fpy_rate": 93.4},
        {"hour_label": "13", "total_defect": 3, "total_output": 100, "yield_rate": 97.0, "fpy_rate": 94.8},
        {"hour_label": "14", "total_defect": 1, "total_output": 108, "yield_rate": 99.1, "fpy_rate": 97.9},
    ]

    return jsonify(demo_data)
