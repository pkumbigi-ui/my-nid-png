# wsgi.py - FIXED IMPORT PATH
import sys
import os

# Add the parent directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app import create_app
from mynid_backend import app  # Import your Flask app
application = create_app()

if __name__ == "__main__":
    application.run()