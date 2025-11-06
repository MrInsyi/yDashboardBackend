from flask import Flask
from flask_cors import CORS
from routes.leak_routes import leak_bp
from routes.yield_routes import yield_bp

app = Flask(__name__)
CORS(app)

# Register routes
app.register_blueprint(leak_bp)
app.register_blueprint(yield_bp)

@app.route("/")
def home():
    return {"status": "Backend is running"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=True)
