# test_nid_insert.py
from extensions import db
from models.application_model import NIDApplication
from app import create_app  # or your Flask app factory
from datetime import datetime

# Initialize Flask app context
app = create_app()
app.app_context().push()

try:
    # Create a test application entry
    test_app = NIDApplication(
        user_id=1,
        birth_cert_entry_no='TEST12345',
        given_names='Test',
        family_name='User',
        gender='Other',
        mobile_no='000000000',
        email='test@example.com',
        place_of_birth='Testville',
        country='Testland',
        province_state='TestState',
        disability='None',
        dob_day='01',
        dob_month='01',
        dob_year='2000',
        mother_given_names='MotherTest',
        mother_family_name='MotherLast',
        mother_nationality='Testland',
        mother_occupation='None',
        mother_denomination='None',
        father_given_names='FatherTest',
        father_family_name='FatherLast',
        father_nationality='Testland',
        father_occupation='None',
        father_denomination='None',
        origin_province='TestProvince',
        origin_district='TestDistrict',
        origin_village='TestVillage',
        origin_llg='TestLLG',
        origin_ward='TestWard',
        origin_tribe='TestTribe',
        origin_clan='TestClan',
        society_type='TestType',
        current_province='TestProvince',
        current_district='TestDistrict',
        current_village='TestVillage',
        current_llg='TestLLG',
        current_ward='TestWard',
        marital_status='Single',
        education_level='None',
        occupation='None',
        denomination='None',
        witness_given_names='Witness',
        witness_family_name='WitnessLast',
        witness_province='TestProvince',
        witness_district='TestDistrict',
        witness_ward='TestWard',
        witness_llg='TestLLG',
        witness_village='TestVillage',
        witness_occupation='None',
        witness_signature='None',
        applicant_signature='None',
        # ✅ Test the new biometric fields
        face_photo_filename='test_face.jpg',
        face_photo_path='/path/to/test_face.jpg',
        fingerprint_data={'total_fingers': 10, 'captured_count': 0},
        status='pending',
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow()
    )

    db.session.add(test_app)
    db.session.commit()
    print("✅ Test insert successful! ID:", test_app.id)

except Exception as e:
    print("❌ Error inserting test row:", e)
