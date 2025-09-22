# models/application_model.py
from flask import url_for
from extensions import db
from datetime import datetime
import json

class NIDApplication(db.Model):
    __tablename__ = 'nid_applications'

    # Primary Key
    id = db.Column(db.Integer, primary_key=True)

    # 🔖 Foreign Key to User
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)

    # Section A: Applicant's Details
    birth_cert_entry_no = db.Column(db.String(50), nullable=False)
    given_names = db.Column(db.String(100), nullable=False)
    family_name = db.Column(db.String(100), nullable=False)
    gender = db.Column(db.String(10), nullable=False)
    mobile_no = db.Column(db.String(15), nullable=False)
    email = db.Column(db.String(100), nullable=True)
    place_of_birth = db.Column(db.String(100), nullable=True)
    country = db.Column(db.String(50), nullable=False)
    province_state = db.Column(db.String(50), nullable=False)
    disability = db.Column(db.String(100), nullable=True)

    # Date of Birth
    dob_day = db.Column(db.String(2), nullable=False)
    dob_month = db.Column(db.String(2), nullable=False)
    dob_year = db.Column(db.String(4), nullable=False)

    # Mother's Details
    mother_nid_no = db.Column(db.String(20), nullable=True)
    mother_given_names = db.Column(db.String(100), nullable=False)
    mother_family_name = db.Column(db.String(100), nullable=False)
    mother_nationality = db.Column(db.String(50), nullable=False)
    mother_occupation = db.Column(db.String(50), nullable=False)
    mother_denomination = db.Column(db.String(50), nullable=False)
    mother_country_origin = db.Column(db.String(50), nullable=False)
    mother_province_origin = db.Column(db.String(50), nullable=False)
    mother_district_origin = db.Column(db.String(50), nullable=False)
    mother_llg_origin = db.Column(db.String(50), nullable=False)
    mother_ward_origin = db.Column(db.String(50), nullable=False)
    mother_village_origin = db.Column(db.String(50), nullable=False)
    mother_tribe_origin = db.Column(db.String(50), nullable=False)
    mother_clan_origin = db.Column(db.String(50), nullable=False)

    # Father's Details
    father_nid_no = db.Column(db.String(20), nullable=True)
    father_given_names = db.Column(db.String(100), nullable=False)
    father_family_name = db.Column(db.String(100), nullable=False)
    father_nationality = db.Column(db.String(50), nullable=False)
    father_occupation = db.Column(db.String(50), nullable=False)
    father_denomination = db.Column(db.String(50), nullable=False)
    father_country_origin = db.Column(db.String(50), nullable=False)
    father_province_origin = db.Column(db.String(50), nullable=False)
    father_district_origin = db.Column(db.String(50), nullable=False)
    father_llg_origin = db.Column(db.String(50), nullable=False)
    father_ward_origin = db.Column(db.String(50), nullable=False)
    father_village_origin = db.Column(db.String(50), nullable=False)
    father_tribe_origin = db.Column(db.String(50), nullable=False)
    father_clan_origin = db.Column(db.String(50), nullable=False)

    # Section C: NID Origin & Current Info
    origin_province = db.Column(db.String(50), nullable=False)
    origin_district = db.Column(db.String(50), nullable=False)
    origin_village = db.Column(db.String(50), nullable=False)
    origin_llg = db.Column(db.String(50), nullable=False)
    origin_ward = db.Column(db.String(50), nullable=False)
    origin_tribe = db.Column(db.String(50), nullable=False)
    origin_clan = db.Column(db.String(50), nullable=False)
    society_type = db.Column(db.String(20), nullable=False)

    current_province = db.Column(db.String(50), nullable=False)
    current_district = db.Column(db.String(50), nullable=False)
    current_village = db.Column(db.String(50), nullable=False)
    current_llg = db.Column(db.String(50), nullable=False)
    current_ward = db.Column(db.String(50), nullable=False)

    # Personal Info
    marital_status = db.Column(db.String(20), nullable=False)
    spouse_family_name = db.Column(db.String(100), nullable=True)
    spouse_nid_no = db.Column(db.String(20), nullable=True)
    education_level = db.Column(db.String(30), nullable=False)
    occupation = db.Column(db.String(50), nullable=False)
    denomination = db.Column(db.String(50), nullable=False)

    # Section D: Witness Details
    witness_given_names = db.Column(db.String(100), nullable=False)
    witness_family_name = db.Column(db.String(100), nullable=False)
    witness_nid_no = db.Column(db.String(20), nullable=True)
    witness_province = db.Column(db.String(50), nullable=False)
    witness_district = db.Column(db.String(50), nullable=False)
    witness_ward = db.Column(db.String(50), nullable=False)
    witness_llg = db.Column(db.String(50), nullable=False)
    witness_village = db.Column(db.String(50), nullable=False)
    witness_occupation = db.Column(db.String(50), nullable=False)
    witness_signature = db.Column(db.String(100), nullable=False)

    # Signatures
    applicant_signature = db.Column(db.String(100), nullable=False)

    # ✅ E. Biometric Data (New Fields)
    face_photo_filename = db.Column(db.String(255), nullable=True)        # e.g., face_1756712345.jpg
    face_photo_path = db.Column(db.String(500), nullable=True)            # full server path
    fingerprint_data = db.Column(db.JSON, nullable=True)                  # JSON: captured_count, fingers, etc.

    # Status and timestamps - UPDATED FIELDS
    status = db.Column(db.String(20), default='pending')
    nid_number = db.Column(db.String(10), unique=True, nullable=True)
    approved_at = db.Column(db.DateTime, nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self):
        """Convert application to dictionary for JSON response with nested structure."""
        return {
            # 🔖 Basic Info
            'id': self.id,
            'user_id': self.user_id,
            'birth_cert_entry_no': self.birth_cert_entry_no,
            'given_names': self.given_names,
            'family_name': self.family_name,
            'gender': self.gender,
            'mobile_no': self.mobile_no,
            'email': self.email,
            'place_of_birth': self.place_of_birth,
            'country': self.country,
            'province_state': self.province_state,
            'disability': self.disability,

            # Date of Birth
            'date_of_birth': {
                'day': self.dob_day,
                'month': self.dob_month,
                'year': self.dob_year
            },

            # ✅ RECONSTRUCT NESTED MOTHER STRUCTURE
            'mother': {
                'nid_no': self.mother_nid_no,
                'given_names': self.mother_given_names,
                'family_name': self.mother_family_name,
                'nationality': self.mother_nationality,
                'occupation': self.mother_occupation,
                'denomination': self.mother_denomination,
                'country_of_origin': self.mother_country_origin,
                'province_state': self.mother_province_origin,
                'district': self.mother_district_origin,
                'llg': self.mother_llg_origin,
                'ward': self.mother_ward_origin,
                'village_town': self.mother_village_origin,
                'tribe': self.mother_tribe_origin,
                'clan': self.mother_clan_origin,
            },

            # ✅ RECONSTRUCT NESTED FATHER STRUCTURE
            'father': {
                'nid_no': self.father_nid_no,
                'given_names': self.father_given_names,
                'family_name': self.father_family_name,
                'nationality': self.father_nationality,
                'occupation': self.father_occupation,
                'denomination': self.father_denomination,
                'country_of_origin': self.father_country_origin,
                'province_state': self.father_province_origin,
                'district': self.father_district_origin,
                'llg': self.father_llg_origin,
                'ward': self.father_ward_origin,
                'village_town': self.father_village_origin,
                'tribe': self.father_tribe_origin,
                'clan': self.father_clan_origin,
            },

            # ✅ RECONSTRUCT NESTED NID INFO STRUCTURE
            'nid_info': {
                'place_of_origin': {
                    'province': self.origin_province,
                    'district': self.origin_district,
                    'village_town': self.origin_village,
                    'llg': self.origin_llg,
                    'ward': self.origin_ward,
                    'tribe': self.origin_tribe,
                    'clan': self.origin_clan,
                    'society': self.society_type
                },
                'current_address': {
                    'province': self.current_province,
                    'district': self.current_district,
                    'village_town': self.current_village,
                    'llg': self.current_llg,
                    'ward': self.current_ward
                },
                'marital_status': self.marital_status,
                'spouse_family_name': self.spouse_family_name,
                'spouse_nid_no': self.spouse_nid_no,
                'education': self.education_level,
                'occupation': self.occupation,
                'denomination': self.denomination
            },

            # ✅ RECONSTRUCT NESTED WITNESS STRUCTURE
            'witness': {
                'given_names': self.witness_given_names,
                'family_name': self.witness_family_name,
                'nid_no': self.witness_nid_no,
                'current_address': {
                    'province': self.witness_province,
                    'district': self.witness_district,
                    'ward': self.witness_ward,
                    'llg': self.witness_llg,
                    'village_town': self.witness_village
                },
                'occupation': self.witness_occupation,
                'signature': self.witness_signature
            },

            # ✅ RECONSTRUCT NESTED SIGNATURES STRUCTURE
            'signatures': {
                'applicant': self.applicant_signature
            },

            # Biometric Data
            'face_photo_filename': self.face_photo_filename,
            'face_photo_url': url_for(
                'static',
                filename=f'uploads/biometrics/{self.face_photo_filename}',
                _external=True
            ) if self.face_photo_filename else None,
            'fingerprint_data': self.fingerprint_data or {},

            # Status & Timestamps - UPDATED FIELDS
            'status': self.status,
            'nid_number': self.nid_number,
            'approved_at': self.approved_at.isoformat() + 'Z' if self.approved_at else None,
            'created_at': self.created_at.isoformat() + 'Z' if self.created_at else None,
            'updated_at': self.updated_at.isoformat() + 'Z' if self.updated_at else None,
        }