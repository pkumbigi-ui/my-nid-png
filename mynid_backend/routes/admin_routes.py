# routes/admin_routes.py
from flask import Blueprint, request, jsonify, send_from_directory
from models.user_model import User
from models.application_model import NIDApplication
from extensions import db
from services.nid_service import mint_nid_number
from datetime import datetime
import os

# ✅ FIXED: Added url_prefix to handle /api/admin routes
admin_bp = Blueprint('admin', __name__, url_prefix='/api/admin')

# 🔧 Define upload folder (must match your application_routes.py)
UPLOAD_FOLDER = 'static/uploads/biometrics'

# ✅ Helper: Add full URL to face photo
def _add_biometric_urls(application_dict):
    """Add accessible URLs to biometric data"""
    if application_dict.get('face_photo_filename'):
        # You can change the base URL if using a domain
        base_url = request.host_url.rstrip('/')
        photo_url = f"{base_url}/static/uploads/biometrics/{application_dict['face_photo_filename']}"
        application_dict['face_photo_url'] = photo_url
    return application_dict

# Admin - Get all users
@admin_bp.route('/users', methods=['GET'])  # ✅ FIXED: Removed /admin prefix (handled by blueprint)
def get_all_users():
    try:
        users = User.query.all()
        return jsonify({
            "status": "success",
            "users": [user.to_dict() for user in users]
        }), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


# Admin - Get all applications (with biometric data)
@admin_bp.route('/applications', methods=['GET'])  # ✅ FIXED: Removed /admin prefix
def get_all_applications():
    try:
        applications = NIDApplication.query.all()
        app_list = []
        for app in applications:
            app_data = app.to_dict()
            app_list.append(_add_biometric_urls(app_data))

        # ✅ FIXED: Return EXACT format frontend expects
        return jsonify({
            "applications": app_list  # ← Frontend expects this exact format
        }), 200
        
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


# Admin - Get single application (detailed view)
@admin_bp.route('/application/<int:application_id>', methods=['GET'])  # ✅ FIXED: Removed /admin prefix
def get_application_detail(application_id):
    try:
        application = NIDApplication.query.get_or_404(application_id)
        app_data = application.to_dict()
        app_data = _add_biometric_urls(app_data)

        return jsonify({
            "status": "success",
            "application": app_data
        }), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


# Admin - Verify application (Update status + optional NID number)
@admin_bp.route('/verify/<int:application_id>', methods=['PUT'])  # ✅ FIXED: Removed /admin prefix
def verify_application(application_id):
    try:
        data = request.get_json()
        application = NIDApplication.query.get_or_404(application_id)

        # Update verification fields
        if 'status' in data:
            valid_statuses = ['pending', 'approved', 'rejected']
            if data['status'] not in valid_statuses:
                return jsonify({"status": "error", "message": "Invalid status"}), 400
            application.status = data['status']

        if 'nid_number' in data:
            application.nid_number = data['nid_number']

        if 'remarks' in data:
            application.verification_remarks = data['remarks']

        db.session.commit()

        return jsonify({
            "status": "success",
            "message": "Application updated successfully"
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({"status": "error", "message": str(e)}), 500


# Admin - Approve application and generate NID number
@admin_bp.route('/applications/<int:application_id>/approve', methods=['POST'])  # ✅ FIXED: Removed /admin prefix
def approve_application(application_id):
    try:
        # Find the application
        app = NIDApplication.query.get(application_id)
        if not app:
            return jsonify({"error": "Application not found"}), 404

        if app.status != "pending":
            return jsonify({"error": f"Already {app.status}"}), 400

        # Generate unique NID
        app.nid_number = mint_nid_number()
        app.status = "approved"
        app.approved_at = datetime.utcnow()

        db.session.commit()

        return jsonify({
            "message": "Application approved successfully",
            "id": app.id,
            "nid_number": app.nid_number,
            "status": app.status
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({"status": "error", "message": str(e)}), 500
    
    # Admin - Reject application
@admin_bp.route('/applications/<int:application_id>/reject', methods=['POST'])
def reject_application(application_id):
    try:
        app = NIDApplication.query.get(application_id)
        if not app:
            return jsonify({"error": "Application not found"}), 404

        if app.status != "pending":
            return jsonify({"error": f"Already {app.status}"}), 400

        app.status = "rejected"
        db.session.commit()

        return jsonify({
            "message": "Application rejected successfully",
            "id": app.id,
            "status": app.status
        }), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({"status": "error", "message": str(e)}), 500


# Admin - Track applications by status
@admin_bp.route('/track', methods=['GET'])  # ✅ FIXED: Removed /admin prefix
def track_applications():
    try:
        status = request.args.get('status', 'all')

        query = NIDApplication.query
        if status != 'all':
            query = query.filter_by(status=status)

        applications = query.all()
        app_list = [ _add_biometric_urls(app.to_dict()) for app in applications ]

        return jsonify({
            "status": "success",
            "count": len(app_list),
            "applications": app_list
        }), 200

    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


# Admin - Reports (Statistics)
@admin_bp.route('/reports', methods=['GET'])  # ✅ FIXED: Removed /admin prefix
def get_reports():
    try:
        total_users = User.query.count()
        total_applications = NIDApplication.query.count()
        pending_applications = NIDApplication.query.filter_by(status='pending').count()
        approved_applications = NIDApplication.query.filter_by(status='approved').count()
        rejected_applications = NIDApplication.query.filter_by(status='rejected').count()

        return jsonify({
            "status": "success",
            "reports": {
                "total_users": total_users,
                "total_applications": total_applications,
                "pending_applications": pending_applications,
                "approved_applications": approved_applications,
                "rejected_applications": rejected_applications
            }
        }), 200

    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


# Admin - Serve Biometric Images
@admin_bp.route('/static/uploads/biometrics/<filename>')  # ✅ FIXED: Removed /admin prefix
def serve_biometric_file(filename):
    """Serve uploaded face photos"""
    return send_from_directory(UPLOAD_FOLDER, filename)


# Admin - Schedule (placeholder)
@admin_bp.route('/schedule', methods=['GET'])  # ✅ FIXED: Removed /admin prefix
def get_schedule():
    try:
        return jsonify({
            "status": "success",
            "message": "Schedule endpoint - implement scheduling logic here"
        }), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500