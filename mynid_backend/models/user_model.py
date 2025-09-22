# models/user_model.py
from extensions import db
import bcrypt

class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    given_name = db.Column(db.String(50), nullable=False)
    surname = db.Column(db.String(50), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(128), nullable=False)  # Store bcrypt hash
    role = db.Column(db.String(20), default='user')
    # Removed: created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def set_password(self, password):
        """Hash and set password."""
        self.password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    
    def check_password(self, password):
        """Check if provided password matches hash."""
        return bcrypt.checkpw(password.encode('utf-8'), self.password.encode('utf-8'))
    
    def to_dict(self):
        """Convert user to dictionary for JSON response."""
        return {
            'id': self.id,
            'given_name': self.given_name,
            'surname': self.surname,
            'email': self.email,
            'role': self.role
            # Removed: 'created_at': self.created_at.isoformat()
        }

# Helper functions
def create_user(given_name, surname, email, password, role='user'):
    """Create a new user."""
    try:
        user = User(
            given_name=given_name,
            surname=surname,
            email=email,
            role=role
        )
        user.set_password(password)
        db.session.add(user)
        db.session.commit()
        return user
    except Exception as e:
        db.session.rollback()
        print(f"Error creating user: {e}")
        return None

def get_user_by_email(email):
    """Retrieve user by email."""
    return User.query.filter_by(email=email).first()