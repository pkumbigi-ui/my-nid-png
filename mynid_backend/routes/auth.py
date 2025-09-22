# routes/auth.py
from flask import Blueprint, request, jsonify, current_app
from models.user_model import create_user, get_user_by_email
import jwt
from app import db

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    given_name = data.get('given_name')
    surname = data.get('surname')
    email = data.get('email')
    password = data.get('password')
    role = data.get('role', 'user')

    if not all([given_name, surname, email, password]):
        return jsonify({"message": "Missing required fields"}), 400

    if get_user_by_email(email):
        return jsonify({"message": "Email already exists"}), 409

    user = create_user(given_name, surname, email, password, role)
    if user:
        return jsonify({"message": "User registered successfully"}), 201
    else:
        return jsonify({"message": "Failed to register user"}), 500

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    user = get_user_by_email(email)
    if not user:
        return jsonify({"message": "User not found"}), 404

    if user.check_password(password):
        token = jwt.encode({
            "user_id": user.id,
            "role": user.role
        }, current_app.config['SECRET_KEY'], algorithm="HS256")
        return jsonify({
            "token": token, 
            "role": user.role,
            "user": user.to_dict()
        }), 200
    else:
        return jsonify({"message": "Incorrect password"}), 401