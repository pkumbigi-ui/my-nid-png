# init_db.py
from app import create_app, db
from models import User, NIDApplication

def initialize_database():
    app = create_app()
    
    with app.app_context():
        db.create_all()
        print("Database tables created successfully!")

if __name__ == '__main__':
    initialize_database()