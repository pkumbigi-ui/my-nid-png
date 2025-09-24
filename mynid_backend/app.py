# mynid_backend/app.py
import os
from urllib.parse import urlsplit
from flask import Flask, send_from_directory, jsonify, abort
from flask_cors import CORS
from werkzeug.utils import safe_join
from extensions import db

def _safe_db_display(url: str) -> str:
    if not url:
        return ""
    parts = urlsplit(url)
    redacted_netloc = "****:****@" + parts.netloc.split("@")[-1] if "@" in parts.netloc else parts.netloc
    return f"{parts.scheme}://{redacted_netloc}{parts.path}"

def create_app():
    # Keep static files under /static to avoid clobbering API/auth routes
    app = Flask(__name__, static_folder="build/web", static_url_path="/static")

    # ---------- Load config ----------
    env = os.getenv("FLASK_ENV", "production").lower()
    cfg_map = {
        "production": "config.ProductionConfig",
        "development": "config.DevelopmentConfig",
        "testing": "config.TestingConfig",
    }
    app.config.from_object(cfg_map.get(env, "config.ProductionConfig"))

    # Ensure upload directory exists
    os.makedirs(app.config["UPLOAD_FOLDER"], exist_ok=True)

    # DB init
    db.init_app(app)
    # ---------------------------------

    # ---------- CORS ----------
    cors_origins = app.config.get("CORS_ORIGINS", ["*"])
    CORS(app, resources={
        r"/auth/*": {"origins": cors_origins},
        r"/api/*": {"origins": cors_origins},
        r"/static/uploads/*": {"origins": cors_origins},
    })
    # -------------------------

    # Import models (mapper config side effects)
    from models.user_model import User  # noqa: F401
    from models.application_model import NIDApplication  # noqa: F401

    # Register blueprints
    from routes.auth import auth_bp
    from routes.application_routes import application_bp
    from routes.admin_routes import admin_bp
    app.register_blueprint(auth_bp, url_prefix="/auth")
    app.register_blueprint(application_bp, url_prefix="/api")
    app.register_blueprint(admin_bp, url_prefix="/api/admin")

    # -------- Health checks --------
    @app.get("/healthz")
    def healthz():
        return jsonify(status="ok"), 200

    @app.get("/health")
    def health():
        return jsonify(
            status="healthy",
            upload_dir=app.config["UPLOAD_FOLDER"],
            database=_safe_db_display(app.config.get("SQLALCHEMY_DATABASE_URI", "")),
            env=env,
        ), 200
    # --------------------------------

    # Serve uploaded biometrics
    @app.get("/static/uploads/biometrics/<path:filename>")
    def uploaded_biometric_file(filename):
        path = safe_join(app.config["UPLOAD_FOLDER"], filename)
        if not path or not os.path.exists(path):
            abort(404)
        return send_from_directory(app.config["UPLOAD_FOLDER"], filename)

    # Debug route to list all rules
    @app.get("/routes")
    def list_routes():
        import urllib
        output = []
        for rule in app.url_map.iter_rules():
            methods = ",".join(sorted(rule.methods))
            line = urllib.parse.unquote(f"{rule.endpoint:50s} {methods:20s} {rule}")
            output.append(line)
        return "<pre>" + "\n".join(sorted(output)) + "</pre>"

    # -------- Flutter SPA routing --------
    @app.get("/")
    def root():
        index_path = os.path.join(app.static_folder, "index.html")
        return (send_from_directory(app.static_folder, "index.html")
                if os.path.exists(index_path) else ("index.html not found", 404))

    @app.route("/<path:path>")
    def spa_fallback(path):
        # Let real endpoints work first
        if path.startswith(("api/", "auth/", "static/", "health", "healthz")):
            abort(404)
        # Serve asset if it exists, else SPA index
        file_path = os.path.join(app.static_folder, path)
        if os.path.exists(file_path) and os.path.isfile(file_path):
            return send_from_directory(app.static_folder, path)
        index_path = os.path.join(app.static_folder, "index.html")
        return (send_from_directory(app.static_folder, "index.html")
                if os.path.exists(index_path) else ("index.html not found", 404))
    # -------------------------------------

    # Dev-only: auto-create tables (migrations recommended for prod)
    if env == "development":
        with app.app_context():
            db.create_all()
            print("✅ Database tables created (development only).")
            print(f"📌 Using database: {_safe_db_display(app.config.get('SQLALCHEMY_DATABASE_URI',''))}")
            print(f"📁 Upload directory: {app.config['UPLOAD_FOLDER']}")

    return app

# For local runs: `python app.py`
if __name__ == "__main__":
    app = create_app()
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "5000")), debug=(env == "development"))
