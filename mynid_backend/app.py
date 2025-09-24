from flask import Flask, send_from_directory
from extensions import db
from flask_cors import CORS
import os

def create_app():
    app = Flask(__name__, static_folder=None)  # disable default static folder
    app.config.from_object('config.Config')

    # Make sure upload folder exists
    os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

    # Initialize extensions
    db.init_app(app)

    # CORS for API routes
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

    # Serve Flutter web build
    @app.route('/', defaults={'path': ''})
    @app.route('/<path:path>')
    def serve_frontend(path):
        frontend_dir = os.path.join(os.getcwd(), 'frontend')
        if path != "" and os.path.exists(os.path.join(frontend_dir, path)):
            return send_from_directory(frontend_dir, path)
        return send_from_directory(frontend_dir, 'index.html')

    # Health check
    @app.route('/health')
    def health():
        return {
            "status": "healthy",
            "upload_dir": app.config['UPLOAD_FOLDER'],
            "database": app.config['SQLALCHEMY_DATABASE_URI']
        }

    # Create database tables
    with app.app_context():
        db.create_all()
        print("✅ Tables created!")
        print(f"📌 Database: {app.config['SQLALCHEMY_DATABASE_URI']}")
        print(f"📁 Upload folder: {app.config['UPLOAD_FOLDER']}")

    return app


if __name__ == '__main__':
    app = create_app()
    app.run(host='0.0.0.0', port=int(os.environ.get("PORT", 5000)), debug=True)








