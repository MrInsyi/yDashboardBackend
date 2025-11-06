from flask import Blueprint, jsonify
from mes import run_query

yield_bp = Blueprint("yield_bp", __name__)

@yield_bp.route("/api/defect_yield", methods=["GET"])
def get_defect_yield():
    """
    Return 30-day defect vs yield data for station 10
    """
    try:
        with open("queries/defect_yield.sql", "r") as f:
            sql = f.read()

        data = run_query(sql)
        return jsonify(data)

    except Exception as e:
        return jsonify({"error": str(e)}), 500
