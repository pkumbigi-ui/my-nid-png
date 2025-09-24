import os

class Config:
    BASE_URL = os.environ.get('BASE_URL', 'http://localhost:5000')

    # 🔹 Use DATABASE_URL from environment if available, fallback to your Render URL
    SQLALCHEMY_DATABASE_URI = os.environ.get(
        "DATABASE_URL",
        "postgresql://mynid_user:Lir5Xa30ju3G73gEaH4RCj2HZzAwVB0z@dpg-d38meuur433s73fmc5m0-a.render.com:5432/mynid"
    ).replace("postgres://", "postgresql://")

    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # Flask secret key
    SECRET_KEY = os.environ.get("SECRET_KEY", "supersecretkey123")
