// AdminReviewApplicationPage.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminReviewApplicationPage extends StatefulWidget {
  final Map<String, dynamic> application;
  const AdminReviewApplicationPage({super.key, required this.application});

  @override
  State<AdminReviewApplicationPage> createState() => _AdminReviewApplicationPageState();
}

class _AdminReviewApplicationPageState extends State<AdminReviewApplicationPage> {
  String? _selectedGender;
  String? _societyType;
  String? _maritalStatus;
  String? _educationLevel;

  // 🔽 Office Use Input Controllers
  final TextEditingController _registrationDayController = TextEditingController();
  final TextEditingController _registrationMonthController = TextEditingController();
  final TextEditingController _registrationYearController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _llgController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _wardController = TextEditingController();
  final TextEditingController _regPointController = TextEditingController();
  final TextEditingController _nidNoController = TextEditingController();
  final TextEditingController _officerNameController = TextEditingController();


  @override
  void initState() {
    super.initState();
    final app = widget.application;

    // Initialize Office Use Fields
    final regDate = _safeMap(app['registration_date']);
    _registrationDayController.text = regDate['day']?.toString() ?? '';
    _registrationMonthController.text = regDate['month']?.toString() ?? '';
    _registrationYearController.text = regDate['year']?.toString() ?? '';

    _provinceController.text = app['province']?.toString() ?? '';
    _llgController.text = app['llg']?.toString() ?? '';
    _districtController.text = app['district']?.toString() ?? '';
    _wardController.text = app['ward']?.toString() ?? '';
    _regPointController.text = app['registration_point']?.toString() ?? '';
    _nidNoController.text = app['nid_no']?.toString() ?? '';
    _officerNameController.text = app['officer_name']?.toString() ?? '';

    // Initialize Selections
    _selectedGender = app['gender']?.toString();
    _societyType = app['society_type']?.toString();
    _maritalStatus = app['marital_status']?.toString();
    _educationLevel = app['education_level']?.toString();
  }

  @override
  void dispose() {
    _registrationDayController.dispose();
    _registrationMonthController.dispose();
    _registrationYearController.dispose();
    _provinceController.dispose();
    _llgController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _regPointController.dispose();
    _nidNoController.dispose();
    _officerNameController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final app = widget.application;

    // DEBUG: Print the entire application data structure
    print("Application Data: ${app.toString()}");

    // DEBUG: Print specific nested structures
    print("Mother data: ${app['mother']}");
    print("Father data: ${app['father']}");
    print("NID Info: ${app['nid_info']}");

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Review Application",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellowAccent,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormHeader(),
            const SizedBox(height: 20),

            // O. For Office Use Only
            _buildOfficeUseSection(app),
            const SizedBox(height: 20),

            // A. Applicant's Details
            _buildApplicantDetailsSection(app),
            const SizedBox(height: 20),

            // B. Parental Details (Combined Mother and Father)
            _buildParentalDetailsSection(app),
            const SizedBox(height: 20),

            // C. NID Info
            _buildNIDInfoSection(app),
            const SizedBox(height: 20),

            // D. Witness Details
            _buildWitnessDetailsSection(app),
            const SizedBox(height: 20),

            // E. Signatures
            _buildSignatureSection(app),
            const SizedBox(height: 20),

            // F. Biometric Data (Photo & Fingerprint)
            _buildBiometricSection(app),
            const SizedBox(height: 32),

            _buildSubmitButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "INDEPENDENT STATE OF PAPUA NEW GUINEA",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Civil Registration Act (Chapter 304) Amended 2014",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            "NID CARD FOR NEW CITIZENS REGISTRATION FORM",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Form 36",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeUseSection(Map<String, dynamic> app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "O. For Office Use Only",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        _buildRowField(
          label: "Registration Date:",
          child: Row(
            children: [
              _buildSmallField("DD", controller: _registrationDayController),
              const Text(" - "),
              _buildSmallField("MM", controller: _registrationMonthController),
              const Text(" - "),
              _buildSmallField("YYYY", controller: _registrationYearController),
            ],
          ),
        ),
        _buildTwoFields(
          leftLabel: "Province:",
          leftField: _buildMediumField("Enter Province", controller: _provinceController),
          rightLabel: "LLG:",
          rightField: _buildSmallField("LLG", controller: _llgController),
        ),
        _buildTwoFields(
          leftLabel: "District:",
          leftField: _buildMediumField("Enter District", controller: _districtController),
          rightLabel: "Ward:",
          rightField: _buildSmallField("Ward", controller: _wardController),
        ),
        _buildTwoFields(
          leftLabel: "Registration Point:",
          leftField: _buildMediumField("Enter Point", controller: _regPointController),
          rightLabel: "NID No:",
          rightField: _buildSmallField("NID", controller: _nidNoController),
        ),
        _buildRowField(
          label: "Registration Officer's Name:",
          child: _buildWideField("Enter Name", controller: _officerNameController),
        ),
      ],
    );
  }

  Widget _buildApplicantDetailsSection(Map<String, dynamic> app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "A. Child or Applicant's Details:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        _buildTwoFields(
          leftLabel: "*Birth Cert Entry No:",
          leftField: _buildDisplayField(app['birth_cert_entry_no']?.toString(), "Enter Number"),
          rightLabel: "*Date of Birth:",
          rightField: Row(
            children: [
              _buildDisplayField(app['birth_day']?.toString(), "DD"),
              const SizedBox(width: 8),
              _buildDisplayField(app['birth_month']?.toString(), "MM"),
              const SizedBox(width: 8),
              _buildDisplayField(app['birth_year']?.toString(), "YYYY"),
            ],
          ),
        ),
        _buildRowField(
          label: "*Given Name(s):",
          child: _buildDisplayField(app['given_names']?.toString(), "Enter Given Names"),
        ),
        _buildRowField(
          label: "*Family Name:",
          child: _buildDisplayField(app['family_name']?.toString(), "Enter Family Name"),
        ),
        _buildRowField(
          label: "*Gender:",
          child: Row(
            children: [
              Row(
                children: [
                  Radio<String>(
                    value: "Male",
                    groupValue: _selectedGender,
                    onChanged: (value) => setState(() => _selectedGender = value),
                  ),
                  const Text("Male"),
                ],
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  Radio<String>(
                    value: "Female",
                    groupValue: _selectedGender,
                    onChanged: (value) => setState(() => _selectedGender = value),
                  ),
                  const Text("Female"),
                ],
              ),
            ],
          ),
        ),
        _buildRowField(
          label: "*Mobile No:",
          child: _buildDisplayField(app['mobile_no']?.toString(), "Enter Mobile Number"),
        ),
        _buildRowField(
          label: "Email Address:",
          child: _buildDisplayField(app['email']?.toString(), "Enter Email (Optional)"),
        ),
        _buildRowField(
          label: "Place of Birth:",
          child: _buildDisplayField(app['place_of_birth']?.toString(), "Enter Place of Birth"),
        ),
        _buildRowField(
          label: "*Country:",
          child: _buildDisplayField(app['country']?.toString(), "Enter Country"),
        ),
        _buildRowField(
          label: "*Province/State:",
          child: _buildDisplayField(app['province_state']?.toString(), "Enter Province"),
        ),
        _buildRowField(
          label: "*District:",
          child: _buildDisplayField(app['district']?.toString(), "Enter District"),
        ),
        _buildRowField(
          label: "Disability:",
          child: _buildDisplayField(app['disability']?.toString(), "Enter Disability (if any)"),
        ),
      ],
    );
  }

  Widget _buildParentalDetailsSection(Map<String, dynamic> app) {
    // ✅ CORRECT: Access the nested mother and father objects
    final mother = _safeMap(app['mother']);
    final father = _safeMap(app['father']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "B. Parents' Details:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        // Two-column layout for Mother and Father
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mother's Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "MOTHER",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRowField(
                    label: "NID No:",
                    child: _buildDisplayField(mother['nid_no']?.toString(), "Enter NID No"),
                  ),
                  _buildRowField(
                    label: "*Given Name(s):",
                    child: _buildDisplayField(mother['given_names']?.toString(), "Enter Given Names"),
                  ),
                  _buildRowField(
                    label: "*Family Name:",
                    child: _buildDisplayField(mother['family_name']?.toString(), "Enter Family Name"),
                  ),
                  _buildRowField(
                    label: "*Date of Birth:",
                    child: _buildDisplayField(mother['date_of_birth']?.toString(), "Enter Date of Birth"),
                  ),
                  _buildRowField(
                    label: "*Nationality:",
                    child: _buildDisplayField(mother['nationality']?.toString(), "Enter Nationality"),
                  ),
                  _buildRowField(
                    label: "*Occupation:",
                    child: _buildDisplayField(mother['occupation']?.toString(), "Enter Occupation"),
                  ),
                  _buildRowField(
                    label: "*Denomination:",
                    child: _buildDisplayField(mother['denomination']?.toString(), "Enter Denomination"),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Place of Origin:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  _buildRowField(
                    label: "*Country:",
                    child: _buildDisplayField(mother['country_of_origin']?.toString(), "Enter Country"),
                  ),
                  _buildRowField(
                    label: "*Province/State:",
                    child: _buildDisplayField(mother['province_state']?.toString(), "Enter Province/State"),
                  ),
                  _buildRowField(
                    label: "*District:",
                    child: _buildDisplayField(mother['district']?.toString(), "Enter District"),
                  ),
                  _buildRowField(
                    label: "*LLG:",
                    child: _buildDisplayField(mother['llg']?.toString(), "Enter LLG"),
                  ),
                  _buildRowField(
                    label: "*Ward:",
                    child: _buildDisplayField(mother['ward']?.toString(), "Enter Ward"),
                  ),
                  _buildRowField(
                    label: "*Village/Town:",
                    child: _buildDisplayField(mother['village_town']?.toString(), "Enter Village/Town"),
                  ),
                  _buildRowField(
                    label: "*Tribe:",
                    child: _buildDisplayField(mother['tribe']?.toString(), "Enter Tribe"),
                  ),
                  _buildRowField(
                    label: "*Clan:",
                    child: _buildDisplayField(mother['clan']?.toString(), "Enter Clan"),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Father's Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "FATHER",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildRowField(
                    label: "NID No:",
                    child: _buildDisplayField(father['nid_no']?.toString(), "Enter NID No"),
                  ),
                  _buildRowField(
                    label: "*Given Name(s):",
                    child: _buildDisplayField(father['given_names']?.toString(), "Enter Given Names"),
                  ),
                  _buildRowField(
                    label: "*Family Name:",
                    child: _buildDisplayField(father['family_name']?.toString(), "Enter Family Name"),
                  ),
                  _buildRowField(
                    label: "*Date of Birth:",
                    child: _buildDisplayField(father['date_of_birth']?.toString(), "Enter Date of Birth"),
                  ),
                  _buildRowField(
                    label: "*Nationality:",
                    child: _buildDisplayField(father['nationality']?.toString(), "Enter Nationality"),
                  ),
                  _buildRowField(
                    label: "*Occupation:",
                    child: _buildDisplayField(father['occupation']?.toString(), "Enter Occupation"),
                  ),
                  _buildRowField(
                    label: "*Denomination:",
                    child: _buildDisplayField(father['denomination']?.toString(), "Enter Denomination"),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Place of Origin:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  _buildRowField(
                    label: "*Country:",
                    child: _buildDisplayField(father['country_of_origin']?.toString(), "Enter Country"),
                  ),
                  _buildRowField(
                    label: "*Province/State:",
                    child: _buildDisplayField(father['province_state']?.toString(), "Enter Province/State"),
                  ),
                  _buildRowField(
                    label: "*District:",
                    child: _buildDisplayField(father['district']?.toString(), "Enter District"),
                  ),
                  _buildRowField(
                    label: "*LLG:",
                    child: _buildDisplayField(father['llg']?.toString(), "Enter LLG"),
                  ),
                  _buildRowField(
                    label: "*Ward:",
                    child: _buildDisplayField(father['ward']?.toString(), "Enter Ward"),
                  ),
                  _buildRowField(
                    label: "*Village/Town:",
                    child: _buildDisplayField(father['village_town']?.toString(), "Enter Village/Town"),
                  ),
                  _buildRowField(
                    label: "*Tribe:",
                    child: _buildDisplayField(father['tribe']?.toString(), "Enter Tribe"),
                  ),
                  _buildRowField(
                    label: "*Clan:",
                    child: _buildDisplayField(father['clan']?.toString(), "Enter Clan"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNIDInfoSection(Map<String, dynamic> app) {
    // ✅ CORRECT: Access the nested nid_info object
    final nidInfo = _safeMap(app['nid_info']);
    final origin = _safeMap(nidInfo['place_of_origin']);
    final current = _safeMap(nidInfo['current_address']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "C. National Identity Card Information:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text("Place of Origin:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),

        // ✅ CORRECT: Access nested origin data
        _buildRowField(
          label: "*Province:",
          child: _buildDisplayField(origin['province']?.toString(), "Enter Province"),
        ),
        _buildRowField(
          label: "*District:",
          child: _buildDisplayField(origin['district']?.toString(), "Enter District"),
        ),
        _buildRowField(
          label: "*Village/Town:",
          child: _buildDisplayField(origin['village_town']?.toString(), "Enter Village/Town"),
        ),
        _buildRowField(
          label: "*LLG:",
          child: _buildDisplayField(origin['llg']?.toString(), "Enter LLG"),
        ),
        _buildRowField(
          label: "*Ward:",
          child: _buildDisplayField(origin['ward']?.toString(), "Enter Ward"),
        ),
        _buildRowField(
          label: "*Tribe:",
          child: _buildDisplayField(origin['tribe']?.toString(), "Enter Tribe"),
        ),
        _buildRowField(
          label: "*Clan:",
          child: _buildDisplayField(origin['clan']?.toString(), "Enter Clan"),
        ),
        _buildRowField(
          label: "*Society Type:",
          child: _buildDisplayField(origin['society']?.toString(), "Enter Society Type"),
        ),
        const SizedBox(height: 16),
        const Text("Current Address:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        _buildRowField(
          label: "*Province:",
          child: _buildDisplayField(current['province']?.toString(), "Enter Province"),
        ),
        _buildRowField(
          label: "*District:",
          child: _buildDisplayField(current['district']?.toString(), "Enter District"),
        ),
        _buildRowField(
          label: "*Village/Town:",
          child: _buildDisplayField(current['village_town']?.toString(), "Enter Village/Town"),
        ),
        _buildRowField(
          label: "*LLG:",
          child: _buildDisplayField(current['llg']?.toString(), "Enter LLG"),
        ),
        _buildRowField(
          label: "*Ward:",
          child: _buildDisplayField(current['ward']?.toString(), "Enter Ward"),
        ),
        const SizedBox(height: 16),
        _buildRowField(
          label: "*Marital Status:",
          child: _buildDisplayField(_maritalStatus, "Select Marital Status"),
        ),
        _buildRowField(
          label: "Preferred Spouse Family Name:",
          child: _buildDisplayField(nidInfo['spouse_family_name']?.toString(), "Enter Spouse Family Name"),
        ),
        _buildRowField(
          label: "Spouse NID No/Name:",
          child: _buildDisplayField(nidInfo['spouse_nid_no']?.toString(), "Enter Spouse NID No or Name"),
        ),
        _buildRowField(
          label: "*Education:",
          child: _buildDisplayField(_educationLevel, "Select Education Level"),
        ),
        _buildRowField(
          label: "*Occupation:",
          child: _buildDisplayField(nidInfo['occupation']?.toString(), "Enter Occupation"),
        ),
        _buildRowField(
          label: "*Denomination:",
          child: _buildDisplayField(nidInfo['denomination']?.toString(), "Enter Denomination"),
        ),
      ],
    );
  }

  Widget _buildWitnessDetailsSection(Map<String, dynamic> app) {
    // ✅ CORRECT: Access the nested witness object
    final witness = _safeMap(app['witness']);
    final address = _safeMap(witness['current_address']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "D. Witness Details:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        // ✅ CORRECT: Access nested witness data
        _buildRowField(
          label: "*Given Name(s):",
          child: _buildDisplayField(witness['given_names']?.toString(), "Enter Given Names"),
        ),
        _buildRowField(
          label: "*Family Name:",
          child: _buildDisplayField(witness['family_name']?.toString(), "Enter Family Name"),
        ),
        _buildRowField(
          label: "NID No:",
          child: _buildDisplayField(witness['nid_no']?.toString(), "Enter NID No"),
        ),
        const Text("Current Address:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        _buildRowField(
          label: "*Province:",
          child: _buildDisplayField(address['province']?.toString(), "Enter Province"),
        ),
        _buildRowField(
          label: "*District:",
          child: _buildDisplayField(address['district']?.toString(), "Enter District"),
        ),
        _buildRowField(
          label: "*Ward:",
          child: _buildDisplayField(address['ward']?.toString(), "Enter Ward"),
        ),
        _buildRowField(
          label: "*LLG:",
          child: _buildDisplayField(address['llg']?.toString(), "Enter LLG"),
        ),
        _buildRowField(
          label: "*Village/Town:",
          child: _buildDisplayField(address['village_town']?.toString(), "Enter Village/Town"),
        ),
        _buildRowField(
          label: "*Occupation:",
          child: _buildDisplayField(witness['occupation']?.toString(), "Enter Occupation"),
        ),
        _buildRowField(
          label: "*Signature:",
          child: _buildDisplayField(witness['signature']?.toString(), "Enter Signature"),
        ),
      ],
    );
  }

  Widget _buildSignatureSection(Map<String, dynamic> app) {
    // ✅ CORRECT: Access the nested signatures object
    final signatures = _safeMap(app['signatures']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "E. Signatures:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        _buildRowField(
          label: "*Applicant's Signature/Mark:",
          // ✅ CORRECT: Access nested signature data
          child: _buildDisplayField(signatures['applicant']?.toString(), "Enter Signature"),
        ),
      ],
    );
  }

  Widget _buildBiometricSection(Map<String, dynamic> app) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "F. Biometric Data:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        // 📸 Face Photo - Positioned in top-left corner
        const Text("Face Photo:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft, // This aligns the photo to the left
          child: _buildFacePhotoDisplay(app),
        ),
        const SizedBox(height: 16),

        // 🖐️ Fingerprint Data - Stays as it was
        const Text("Fingerprint Status:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildFingerprintDisplay(app),
      ],
    );
  }

  Widget _buildFacePhotoDisplay(Map<String, dynamic> app) {
    // ✅ Use the pre-built URL from backend (face_photo_url)
    final String? facePhotoUrl = app['face_photo_url']?.toString();

    // 🔍 DEBUG: Log the URL for troubleshooting
    print("DEBUG: Using face_photo_url for display: '$facePhotoUrl'");

    return SizedBox(
      width: 120,
      height: 120,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[100],
        ),
        child: facePhotoUrl == null || facePhotoUrl.isEmpty
            ? const Center(
          child: Text(
            "No photo\nuploaded",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10),
          ),
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            facePhotoUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print("❌ ERROR loading image from URL: $facePhotoUrl");
              print("❌ Error details: $error");
              return const Center(
                child: Text(
                  "Failed to load\nimage",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.red),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFingerprintDisplay(Map<String, dynamic> app) {
    final dynamic fingerprintData = app['fingerprint_data'];
    final Map<String, dynamic> data = _safeMap(fingerprintData);
    final int capturedCount = data['captured_count'] != null
        ? int.tryParse(data['captured_count'].toString()) ?? 0
        : 0;
    final List<dynamic> capturedFingers = data['captured_fingers'] is List
        ? data['captured_fingers']
        : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: capturedFingers.map((f) {
            return Chip(
              label: Text(f.toString().split(' ').last),
              backgroundColor: Colors.green[100],
              avatar: const Icon(Icons.fingerprint, size: 16, color: Colors.green),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        Text("Fingers Captured: $capturedCount/10"),
        if (capturedCount == 10)
          const Text("✅ All fingers captured", style: TextStyle(color: Colors.green)),
        if (capturedCount < 10)
          const Text("⚠️ Incomplete fingerprint capture", style: TextStyle(color: Colors.orange)),
      ],
    );
  }

  Widget _buildSubmitButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          onPressed: () => _confirmAction("rejected"),
          child: const Text(
            "Reject",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          onPressed: () => _confirmAction("approved"),
          child: const Text(
            "Approve",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }

  void _confirmAction(String status) async {
    // ✅ NULL SAFETY CHECK
    if (widget.application == null || widget.application['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Invalid application data")),
      );
      return;
    }

    // Validate office section first
    final List<String> emptyFields = [];

    if (_registrationDayController.text.isEmpty) emptyFields.add("Registration Day");
    if (_registrationMonthController.text.isEmpty) emptyFields.add("Registration Month");
    if (_registrationYearController.text.isEmpty) emptyFields.add("Registration Year");
    if (_provinceController.text.isEmpty) emptyFields.add("Province");
    if (_llgController.text.isEmpty) emptyFields.add("LLG");
    if (_districtController.text.isEmpty) emptyFields.add("District");
    if (_wardController.text.isEmpty) emptyFields.add("Ward");
    if (_regPointController.text.isEmpty) emptyFields.add("Registration Point");
    if (_nidNoController.text.isEmpty) emptyFields.add("NID No");
    if (_officerNameController.text.isEmpty) emptyFields.add("Officer Name");

    if (emptyFields.isNotEmpty) {
      final errorMessage = "Please complete all Office Use fields:\n${emptyFields.join(', ')}";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirm $status"),
        content: Text("Are you sure you want to $status this application?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );

              try {
                final int applicationId = widget.application['id'];
                final String url = status == "approved"
                    ? "http://127.0.0.1:5000/api/admin/applications/$applicationId/approve"
                    : "http://127.0.0.1:5000/api/admin/applications/$applicationId/reject";

                final response = await http.post(Uri.parse(url));

                Navigator.pop(context); // Close loading

                if (response.statusCode == 200) {
                  final responseData = jsonDecode(response.body);
                  String message;

                  if (status == "approved") {
                    final String? nidNumber = responseData['nid_number'];
                    message = nidNumber != null
                        ? "✅ Approved! NID: $nidNumber"
                        : "✅ Application approved.";
                  } else {
                    message = "❌ Application rejected.";
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );

                  // Go back to list
                  if (Navigator.canPop(context)) Navigator.pop(context);
                  if (Navigator.canPop(context)) Navigator.pop(context);

                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("❌ Server error: ${response.statusCode}")),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("❌ Network error: $e")),
                );
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
  Widget _buildRowField({required String label, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildTwoFields({
    required String leftLabel,
    required Widget leftField,
    required String rightLabel,
    required Widget rightField,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              SizedBox(
                width: 140,
                child: Text(
                  leftLabel,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: leftField),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  rightLabel,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: rightField),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallField(String hint, {required TextEditingController controller}) {
    return SizedBox(
      width: 60,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }

  Widget _buildMediumField(String hint, {required TextEditingController controller}) {
    return SizedBox(
      width: 150,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }

  Widget _buildWideField(String hint, {required TextEditingController controller}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  Widget _buildDisplayField(String? value, String hint) {
    if (value != null && value.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
          color: Colors.grey[100],
        ),
        child: Text(
          hint,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      );
    }
  }

  Map<String, dynamic> _safeMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }
}