import os

class Config:
    BASE_URL = os.environ.get('BASE_URL', 'http://localhost:5000')
    # PostgreSQL configuration
    DB_HOST = "localhost"
    DB_NAME = "mynid"
    DB_USER = "postgres"
    DB_PASSWORD = "psn%40dwu143"  # Replace with your real password
    DB_PORT = 5432
    
    # Flask secret key
    SECRET_KEY = os.environ.get("SECRET_KEY", "supersecretkey123")
    
    # SQLAlchemy database configuration
    SQLALCHEMY_DATABASE_URI = os.environ.get("DATABASE_URL", f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}")
    if SQLALCHEMY_DATABASE_URI.startswith("postgres://"):
        SQLALCHEMY_DATABASE_URI = SQLALCHEMY_DATABASE_URI.replace("postgres://", "postgresql://", 1)

    SQLALCHEMY_TRACK_MODIFICATIONS = False
