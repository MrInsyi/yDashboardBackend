from flask import Flask
from flask_cors import CORS
from routes.leak_routes import leak_bp
from routes.yield_routes import yield_bp
from routes.leak_routes_hourly import leak_h
from routes.qc_checksheet import qc_checksheet

app = Flask(__name__)
CORS(app)

# Register routes
app.register_blueprint(leak_bp)                 # Leak Monthly
app.register_blueprint(yield_bp)                # Yield vs Defect
app.register_blueprint(leak_h)                  # Leak Hourly
app.register_blueprint(qc_checksheet)           # QC Checksheet

@app.route("/")
def home():
    return {"status": "Backend is running"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
