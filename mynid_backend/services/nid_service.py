# services/nid_service.py
import random
from models.application_model import NIDApplication
from extensions import db

def mint_nid_number():
    """Generate a guaranteed unique 10-digit NID number."""
    while True:
        nid = str(random.randint(1000000000, 9999999999))
        existing = NIDApplication.query.filter_by(nid_number=nid).first()
        if not existing:
            return nid