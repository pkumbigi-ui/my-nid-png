# routes/application_routes.py
from flask import Blueprint, request, jsonify
from models.application_model import NIDApplication
from extensions import db
import os
import json
from werkzeug.utils import secure_filename
from datetime import datetime
import random

application_bp = Blueprint('application', __name__)

# 🔧 File Upload Settings
UPLOAD_FOLDER = 'static/uploads/biometrics'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in {'png', 'jpg', 'jpeg'}

def generate_nid_number():
    """Generate a unique 10-digit PNG NID"""
    return str(random.randint(10**9, 10**10 - 1))


@application_bp.route('/submit-nid-form', methods=['POST'])
def submit_nid_form():
    try:
        # 🔴 Debug: Log what's actually in the request
        print("Form keys:", request.form.keys())
        print("Files keys:", request.files.keys())

        # ✅ Step 1: Get 'data' from form
        json_data = request.form.get('data')
        if not json_data:
            return jsonify({
                "status": "error",
                "message": "Form data is missing. Expected 'data' field in form.",
                "received_form_keys": list(request.form.keys()),
                "received_files": list(request.files.keys())
            }), 400

        # ✅ Step 2: Parse JSON
        try:
            data = json.loads(json_data)
        except json.JSONDecodeError as e:
            return jsonify({
                "status": "error",
                "message": f"Invalid JSON in 'data' field: {str(e)}"
            }), 400

        # ✅ Step 3: Validate user_id
        user_id = data.get('user_id')
        if not user_id:
            return jsonify({"status": "error", "message": "User ID is required"}), 400

        # ✅ Step 4: Handle Face Photo Upload
        face_photo_filename = None
        face_photo_path = None

        if 'face_photo' in request.files:
            file = request.files['face_photo']
            if file and file.filename != '':
                if allowed_file(file.filename):
                    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                    original_filename = secure_filename(file.filename)
                    face_photo_filename = f"{timestamp}_{original_filename}"
                    face_photo_path = os.path.join(UPLOAD_FOLDER, face_photo_filename)
                    file.save(face_photo_path)
                    print(f"✅ Saved face photo: {face_photo_path}")
                else:
                    return jsonify({
                        "status": "error",
                        "message": "Invalid file type. Only .jpg, .jpeg, .png allowed."
                    }), 400
            else:
                return jsonify({"status": "error", "message": "Empty file received"}), 400
        else:
            print("⚠️ No 'face_photo' file in request")

        # ✅ Step 5: Parse fingerprint data
        fingerprint_status = {}
        if 'biometrics' in data and isinstance(data['biometrics'], dict):
            fingerprint_status = data['biometrics'].get('fingerprint_status', {})

        # ✅ Step 6: Create and save application
        application = NIDApplication(
            user_id=user_id,
            birth_cert_entry_no=data.get('birth_cert_entry_no', ''),
            given_names=data.get('given_names', ''),
            family_name=data.get('family_name', ''),
            gender=data.get('gender', ''),
            mobile_no=data.get('mobile_no', ''),
            email=data.get('email', ''),
            place_of_birth=data.get('place_of_birth', ''),
            country=data.get('country', ''),
            province_state=data.get('province_state', ''),
            disability=data.get('disability', ''),

            # Date of Birth
            dob_day=str(data.get('date_of_birth', {}).get('day', '')),
            dob_month=str(data.get('date_of_birth', {}).get('month', '')),
            dob_year=str(data.get('date_of_birth', {}).get('year', '')),

            # Mother
            mother_nid_no=data.get('mother', {}).get('nid_no', ''),
            mother_given_names=data.get('mother', {}).get('given_names', ''),
            mother_family_name=data.get('mother', {}).get('family_name', ''),
            mother_nationality=data.get('mother', {}).get('nationality', ''),
            mother_occupation=data.get('mother', {}).get('occupation', ''),
            mother_denomination=data.get('mother', {}).get('denomination', ''),
            mother_country_origin=data.get('mother', {}).get('country_of_origin', ''),
            mother_province_origin=data.get('mother', {}).get('province_state', ''),
            mother_district_origin=data.get('mother', {}).get('district', ''),
            mother_llg_origin=data.get('mother', {}).get('llg', ''),
            mother_ward_origin=data.get('mother', {}).get('ward', ''),
            mother_village_origin=data.get('mother', {}).get('village_town', ''),
            mother_tribe_origin=data.get('mother', {}).get('tribe', ''),
            mother_clan_origin=data.get('mother', {}).get('clan', ''),

            # Father
            father_nid_no=data.get('father', {}).get('nid_no', ''),
            father_given_names=data.get('father', {}).get('given_names', ''),
            father_family_name=data.get('father', {}).get('family_name', ''),
            father_nationality=data.get('father', {}).get('nationality', ''),
            father_occupation=data.get('father', {}).get('occupation', ''),
            father_denomination=data.get('father', {}).get('denomination', ''),
            father_country_origin=data.get('father', {}).get('country_of_origin', ''),
            father_province_origin=data.get('father', {}).get('province_state', ''),
            father_district_origin=data.get('father', {}).get('district', ''),
            father_llg_origin=data.get('father', {}).get('llg', ''),
            father_ward_origin=data.get('father', {}).get('ward', ''),
            father_village_origin=data.get('father', {}).get('village_town', ''),
            father_tribe_origin=data.get('father', {}).get('tribe', ''),
            father_clan_origin=data.get('father', {}).get('clan', ''),

            # NID Info
            origin_province=data.get('nid_info', {}).get('place_of_origin', {}).get('province', ''),
            origin_district=data.get('nid_info', {}).get('place_of_origin', {}).get('district', ''),
            origin_village=data.get('nid_info', {}).get('place_of_origin', {}).get('village_town', ''),
            origin_llg=data.get('nid_info', {}).get('place_of_origin', {}).get('llg', ''),
            origin_ward=data.get('nid_info', {}).get('place_of_origin', {}).get('ward', ''),
            origin_tribe=data.get('nid_info', {}).get('place_of_origin', {}).get('tribe', ''),
            origin_clan=data.get('nid_info', {}).get('place_of_origin', {}).get('clan', ''),
            society_type=data.get('nid_info', {}).get('place_of_origin', {}).get('society', ''),

            current_province=data.get('nid_info', {}).get('current_address', {}).get('province', ''),
            current_district=data.get('nid_info', {}).get('current_address', {}).get('district', ''),
            current_village=data.get('nid_info', {}).get('current_address', {}).get('village_town', ''),
            current_llg=data.get('nid_info', {}).get('current_address', {}).get('llg', ''),
            current_ward=data.get('nid_info', {}).get('current_address', {}).get('ward', ''),

            marital_status=data.get('nid_info', {}).get('marital_status', ''),
            spouse_family_name=data.get('nid_info', {}).get('spouse_family_name', ''),
            spouse_nid_no=data.get('nid_info', {}).get('spouse_nid_no', ''),
            education_level=data.get('nid_info', {}).get('education', ''),
            occupation=data.get('nid_info', {}).get('occupation', ''),
            denomination=data.get('nid_info', {}).get('denomination', ''),

            # Witness
            witness_given_names=data.get('witness', {}).get('given_names', ''),
            witness_family_name=data.get('witness', {}).get('family_name', ''),
            witness_nid_no=data.get('witness', {}).get('nid_no', ''),
            witness_province=data.get('witness', {}).get('current_address', {}).get('province', ''),
            witness_district=data.get('witness', {}).get('current_address', {}).get('district', ''),
            witness_ward=data.get('witness', {}).get('current_address', {}).get('ward', ''),
            witness_llg=data.get('witness', {}).get('current_address', {}).get('llg', ''),
            witness_village=data.get('witness', {}).get('current_address', {}).get('village_town', ''),
            witness_occupation=data.get('witness', {}).get('occupation', ''),
            witness_signature=data.get('witness', {}).get('signature', ''),

            # Signatures
            applicant_signature=data.get('signatures', {}).get('applicant', ''),

            # 🔹 Biometric Data
            face_photo_filename=face_photo_filename,
            face_photo_path=face_photo_path,
            fingerprint_data=fingerprint_status  # JSON object
        )

        db.session.add(application)
        db.session.commit()

        print(f"✅ Application saved with ID: {application.id}")
        return jsonify({
            "status": "success",
            "message": "Application submitted successfully",
            "application_id": application.id
        }), 200

    except Exception as e:
        db.session.rollback()
        print(f"❌ Error in submit_nid_form: {str(e)}")
        return jsonify({
            "status": "error",
            "message": "Internal server error",
            "error": str(e)
        }), 500


# ✅ For users to get their own applications
@application_bp.route('/my-applications', methods=['GET'])
def get_my_applications():
    try:
        user_id = request.args.get('user_id')
        if not user_id:
            return jsonify({"status": "error", "message": "User ID is required"}), 400

        applications = NIDApplication.query.filter_by(user_id=user_id).all()
        return jsonify({
            "status": "success",
            "applications": [app.to_dict() for app in applications]
        }), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


# ✅ For admin to get ALL applications
@application_bp.route('/applications', methods=['GET'])
def get_applications():
    try:
        applications = NIDApplication.query.all()
        return jsonify({
            "status": "success",
            "applications": [app.to_dict() for app in applications]
        }), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


@application_bp.route('/applications/<int:application_id>', methods=['GET'])
def get_application(application_id):
    try:
        application = NIDApplication.query.get_or_404(application_id)
        return jsonify({
            "status": "success",
            "application": application.to_dict()
        }), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


@application_bp.route('/applications/<int:application_id>/status', methods=['PUT'])
def update_application_status(application_id):
    try:
        data = request.get_json()
        application = NIDApplication.query.get_or_404(application_id)
        
        if 'status' in data:
            application.status = data['status']
        
        db.session.commit()
        
        return jsonify({
            "status": "success", 
            "message": "Application updated successfully"
        }), 200
        
    except Exception as e:
        db.session.rollback()
        return jsonify({"status": "error", "message": str(e)}), 500


@application_bp.route('/applications/<int:app_id>/approve', methods=['PUT'])
def approve_application(app_id):
    application = NIDApplication.query.get(app_id)
    if not application:
        return jsonify({"error": "Application not found"}), 404

    if application.status == "approved":
        return jsonify({"message": "Already approved", "nid_number": application.nid_number}), 200

    application.status = "approved"
    application.nid_number = generate_nid_number()
    application.approved_at = datetime.utcnow()

    db.session.commit()

    return jsonify({
        "message": "Application approved successfully",
        "application_id": application.id,
        "nid_number": application.nid_number
    }), 200


@application_bp.route('/applications/approved', methods=['GET'])
def get_approved_applications():
    applications = NIDApplication.query.filter_by(status="approved").all()

    result = []
    for app in applications:
        result.append({
            "id": app.id,
            "user_id": app.user_id,
            "given_names": app.given_names,
            "family_name": app.family_name,
            "nid_number": app.nid_number,
            "approved_at": app.approved_at
        })

    return jsonify(result), 200