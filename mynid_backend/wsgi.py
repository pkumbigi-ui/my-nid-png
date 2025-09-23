# mynid_backend/wsgi.py
from app import create_app  # works because wsgi.py and app.py are in the same folder

app = create_app()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
