# app.py
from flask import Flask, send_from_directory
from extensions import db
from flask_cors import CORS
import os

def create_app():
    # 👇 set static folder to serve Flutter build
    app = Flask(__name__, static_folder="static")

    # 🔹 Use Render PostgreSQL URL from environment
    app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get(
        'DATABASE_URL',
        'postgresql://postgres:password@localhost:5432/mynid_db'  # fallback for local testing
    )
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    # 🔹 Define and store upload path
    UPLOAD_FOLDER = 'static/uploads/biometrics'
    os.makedirs(UPLOAD_FOLDER, exist_ok=True)
    app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

    # Initialize extensions
    db.init_app(app)

    # ✅ Allow CORS for all relevant routes
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

    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(application_bp, url_prefix='/api')
    app.register_blueprint(admin_bp, url_prefix='/api/admin')

    # Serve uploaded biometric files
    @app.route('/static/uploads/biometrics/<filename>')
    def uploaded_biometric_file(filename):
        return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

    # Debug: List all routes
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

    # 🔹 Serve Flutter web build (fallback for SPA)
    @app.route('/', defaults={'path': ''})
    @app.route('/<path:path>')
    def serve_flutter(path):
        if path != "" and os.path.exists(os.path.join(app.static_folder, path)):
            return send_from_directory(app.static_folder, path)
        return send_from_directory(app.static_folder, 'index.html')

    # Create tables
    with app.app_context():
        db.create_all()
        print("✅ Database tables created successfully!")
        print(f"📌 Using database: {app.config['SQLALCHEMY_DATABASE_URI']}")
        print(f"📁 Upload directory: {app.config['UPLOAD_FOLDER']}")

    return app


if __name__ == '__main__':
    app = create_app()
    app.run(host='0.0.0.0', port=int(os.environ.get("PORT", 5000)), debug=True)

# For production deployment (Gunicorn)
application = create_app()

