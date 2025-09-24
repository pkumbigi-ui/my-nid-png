# app.py
from flask import Flask, send_from_directory
from extensions import db
from flask_cors import CORS
import os

def create_app():
    app = Flask(__name__)
    
    # -----------------------------
    # CONFIG
    # -----------------------------
    # Load from your existing config.py
    app.config.from_object('config.Config')

    # 🔹 Ensure DATABASE_URL uses internal Render Postgres if available
    if os.environ.get("DATABASE_URL"):
        app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get("DATABASE_URL")

    # -----------------------------
    # UPLOAD FOLDER
    # -----------------------------
    UPLOAD_FOLDER = 'static/uploads/biometrics'
    os.makedirs(UPLOAD_FOLDER, exist_ok=True)
    app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

    # -----------------------------
    # INITIALIZE EXTENSIONS
    # -----------------------------
    db.init_app(app)

    # -----------------------------
    # ENABLE CORS
    # -----------------------------
    CORS(app, resources={
        r"/auth/*": {"origins": "*"},
        r"/api/*": {"origins": "*"},
        r"/static/uploads/*": {"origins": "*"}
    })

    # -----------------------------
    # IMPORT MODELS
    # -----------------------------
    from models.user_model import User
    from models.application_model import NIDApplication

    # -----------------------------
    # REGISTER BLUEPRINTS
    # -----------------------------
    from routes.auth import auth_bp
    from routes.application_routes import application_bp
    from routes.admin_routes import admin_bp

    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(application_bp, url_prefix='/api')
    app.register_blueprint(admin_bp, url_prefix='/api/admin')

    # -----------------------------
    # ROUTES
    # -----------------------------
    # Serve uploaded biometric files
    @app.route('/static/uploads/biometrics/<filename>')
    def uploaded_biometric_file(filename):
        return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

    # Serve Flutter web frontend
    @app.route('/', defaults={'path': ''})
    @app.route('/<path:path>')
    def serve_frontend(path):
        frontend_dir = os.path.join(os.getcwd(), 'frontend')  # Adjust to your frontend folder
        if path != "" and os.path.exists(os.path.join(frontend_dir, path)):
            return send_from_directory(frontend_dir, path)
        else:
            return send_from_directory(frontend_dir, 'index.html')

    # List all routes (debug)
    @app.route('/routes')
    def list_routes():
        import urllib
        output = []
        for rule in app.url_map.iter_rules():
            methods = ','.join(sorted(rule.methods))
            line = urllib.parse.unquote(f"{rule.endpoint:50s} {methods:20s} {rule}")
            output.append(line)
        return "<pre>" + "\n".join(sorted(output)) + "</pre>"

    # Health check
    @app.route('/health')
    def health():
        return {
            "status": "healthy",
            "upload_dir": app.config['UPLOAD_FOLDER'],
            "database": app.config['SQLALCHEMY_DATABASE_URI']
        }

    # -----------------------------
    # CREATE DATABASE TABLES
    # -----------------------------
    with app.app_context():
        db.create_all()
        print("✅ Database tables created successfully!")
        print(f"📌 Using database: {app.config['SQLALCHEMY_DATABASE_URI']}")
        print(f"📁 Upload directory: {app.config['UPLOAD_FOLDER']}")

    return app


# -----------------------------
# RUN LOCALLY
# -----------------------------
if __name__ == '__main__':
    app = create_app()
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 5000)), debug=True)







