import os

class Config:
    # Use environment variable DATABASE_URL if available (Render, Heroku, etc.)
    SQLALCHEMY_DATABASE_URI = os.environ.get("DATABASE_URL") or \
        "postgresql://mynid_user:localpassword@localhost/mynid"  # fallback for local dev

    SQLALCHEMY_TRACK_MODIFICATIONS = False
    UPLOAD_FOLDER = os.path.join(os.getcwd(), "static/uploads/biometrics")
