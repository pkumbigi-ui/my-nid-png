from flask import Flask, send_from_directory
from extensions import db
from flask_cors import CORS
import os

def create_app():
    app = Flask(__name__, static_folder="frontend", static_url_path="")

    # ✅ Use DATABASE_URL from environment (Render sets it) and psycopg2
    database_url = os.getenv(
        "DATABASE_URL",
        "postgresql+psycopg2://mynid_user:Lir6Xa30ju3G73gEaH4RQj2HZzAwVBor@dpg-d38meuux433s73fmc5m0-a.render.com:5432/mynid?sslmode=require"
    )
    app.config["SQLALCHEMY_DATABASE_URI"] = database_url
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    # 🔹 Define and store upload path
    UPLOAD_FOLDER = "static/uploads/biometrics"
    os.makedirs(UPLOAD_FOLDER, exist_ok=True)
    app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER

    # Initialize extensions
    db.init_app(app)

    # ✅ Allow CORS for relevant routes
    CORS(app, resources={
        r"/auth/*": {"origins": "*"},
        r"/api/*": {"origins": "*"},
        r"/static/uploads/*": {"origins": "*"}
    })

    # Import models
    from models.user_model import User
    from models.application_model import NIDApplication

    # Register blueprints
    from routes.auth import auth_bp
    from routes.application_routes import application_bp
    from routes.admin_routes import admin_bp

    app.register_blueprint(auth_bp, url_prefix="/auth")
    app.register_blueprint(application_bp, url_prefix="/api")
    app.register_blueprint(admin_bp, url_prefix="/api/admin")

    # Serve uploaded biometric files
    @app.route("/static/uploads/biometrics/<filename>")
    def uploaded_biometric_file(filename):
        return send_from_directory(app.config["UPLOAD_FOLDER"], filename)

    # Serve Flutter frontend
    @app.route("/", defaults={"path": ""})
    @app.route("/<path:path>")
    def serve_frontend(path):
        if path != "" and os.path.exists(os.path.join(app.static_folder, path)):
            return send_from_directory(app.static_folder, path)
        else:
            return send_from_directory(app.static_folder, "index.html")

    # Debug: List all routes
    @app.route("/routes")
    def list_routes():
        import urllib
        output = []
        for rule in app.url_map.iter_rules():
            methods = ",".join(sorted(rule.methods))
            line = urllib.parse.unquote(f"{rule.endpoint:50s} {methods:20s} {rule}")
            output.append(line)
        return "<pre>" + "\n".join(sorted(output)) + "</pre>"

    # Health check
    @app.route("/health")
    def health():
        return {
            "status": "healthy",
            "upload_dir": app.config["UPLOAD_FOLDER"],
            "database": app.config["SQLALCHEMY_DATABASE_URI"]
        }

    # ⚠️ Don’t auto-create tables on every startup in production
    if os.getenv("FLASK_ENV") == "development":
        with app.app_context():
            db.create_all()
            print("✅ Database tables created successfully (development only).")
            print(f"📌 Using database: {app.config['SQLALCHEMY_DATABASE_URI']}")
            print(f"📁 Upload directory: {app.config['UPLOAD_FOLDER']}")

    return app

if __name__ == "__main__":
    app = create_app()
    app.run(host="0.0.0.0", port=5000, debug=True)


