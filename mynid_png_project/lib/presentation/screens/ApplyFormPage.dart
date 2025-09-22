// ApplyFormPage.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';             // For Uint8List (web)
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplyFormPage extends StatefulWidget {
  static const String apiUrl = "http://127.0.0.1:5000/api/submit-nid-form";
  const ApplyFormPage({super.key});

  @override
  State<ApplyFormPage> createState() => _ApplyFormPageState();
}

class _ApplyFormPageState extends State<ApplyFormPage> {
  final _formKey = GlobalKey<FormState>();

  // 🔹 Selections
  String? _selectedGender;
  String? _societyType;
  String? _maritalStatus;
  String? _educationLevel;
  String? _selectedProvince;
  String? _selectedDistrict;

  // 🔹 Controllers for all fields
  // Office Use - Registration Date
  final TextEditingController _regDayController = TextEditingController();
  final TextEditingController _regMonthController = TextEditingController();
  final TextEditingController _regYearController = TextEditingController();

  // Section O (Office Use) Controllers
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _llgController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _wardController = TextEditingController();
  final TextEditingController _regPointController = TextEditingController();
  final TextEditingController _nidNoController = TextEditingController();

  // Applicant DOB
  final TextEditingController _dobDayController = TextEditingController();
  final TextEditingController _dobMonthController = TextEditingController();
  final TextEditingController _dobYearController = TextEditingController();

  // Applicant Details
  final TextEditingController _birthCertEntryNoController = TextEditingController();
  final TextEditingController _givenNameController = TextEditingController();
  final TextEditingController _familyNameController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _placeOfBirthController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _disabilityController = TextEditingController();

  // Mother Fields
  final TextEditingController _motherNidNoController = TextEditingController();
  final TextEditingController _motherGivenNameController = TextEditingController();
  final TextEditingController _motherFamilyNameController = TextEditingController();
  final TextEditingController _motherDateOfBirthController = TextEditingController();
  final TextEditingController _motherNationalityController = TextEditingController();
  final TextEditingController _motherOccupationController = TextEditingController();
  final TextEditingController _motherDenominationController = TextEditingController();
  final TextEditingController _motherCountryOfOriginController = TextEditingController();
  final TextEditingController _motherProvinceStateController = TextEditingController();
  final TextEditingController _motherDistrictController = TextEditingController();
  final TextEditingController _motherLLGController = TextEditingController();
  final TextEditingController _motherWardController = TextEditingController();
  final TextEditingController _motherVillageTownController = TextEditingController();
  final TextEditingController _motherTribeController = TextEditingController();
  final TextEditingController _motherClanController = TextEditingController();

  // Father Fields
  final TextEditingController _fatherNidNoController = TextEditingController();
  final TextEditingController _fatherGivenNameController = TextEditingController();
  final TextEditingController _fatherFamilyNameController = TextEditingController();
  final TextEditingController _fatherDateOfBirthController = TextEditingController();
  final TextEditingController _fatherNationalityController = TextEditingController();
  final TextEditingController _fatherOccupationController = TextEditingController();
  final TextEditingController _fatherDenominationController = TextEditingController();
  final TextEditingController _fatherCountryOfOriginController = TextEditingController();
  final TextEditingController _fatherProvinceStateController = TextEditingController();
  final TextEditingController _fatherDistrictController = TextEditingController();
  final TextEditingController _fatherLLGController = TextEditingController();
  final TextEditingController _fatherWardController = TextEditingController();
  final TextEditingController _fatherVillageTownController = TextEditingController();
  final TextEditingController _fatherTribeController = TextEditingController();
  final TextEditingController _fatherClanController = TextEditingController();

  // Marriage Info
  final TextEditingController _marriageCountryController = TextEditingController();
  final TextEditingController _marriageProvinceStateController = TextEditingController();
  final TextEditingController _marriageDateDayController = TextEditingController();
  final TextEditingController _marriageDateMonthController = TextEditingController();
  final TextEditingController _marriageDateYearController = TextEditingController();
  final TextEditingController _marriageRegNoController = TextEditingController();

  // Section C Controllers
  final TextEditingController _provinceOfOriginController = TextEditingController();
  final TextEditingController _districtOfOriginController = TextEditingController();
  final TextEditingController _villageTownOfOriginController = TextEditingController();
  final TextEditingController _llgOfOriginController = TextEditingController();
  final TextEditingController _wardOfOriginController = TextEditingController();
  final TextEditingController _tribeOfOriginController = TextEditingController();
  final TextEditingController _clanOfOriginController = TextEditingController();
  final TextEditingController _currentProvinceController = TextEditingController();
  final TextEditingController _currentDistrictController = TextEditingController();
  final TextEditingController _currentVillageTownController = TextEditingController();
  final TextEditingController _currentLLGController = TextEditingController();
  final TextEditingController _currentWardController = TextEditingController();
  final TextEditingController _spouseFamilyNameController = TextEditingController();
  final TextEditingController _spouseNidNoController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _denominationController = TextEditingController();

  // Section D: Witness Details
  final TextEditingController _witnessGivenNameController = TextEditingController();
  final TextEditingController _witnessFamilyNameController = TextEditingController();
  final TextEditingController _witnessNidNoController = TextEditingController();
  final TextEditingController _witnessProvinceController = TextEditingController();
  final TextEditingController _witnessLlgController = TextEditingController();
  final TextEditingController _witnessDistrictController = TextEditingController();
  final TextEditingController _witnessWardController = TextEditingController();
  final TextEditingController _witnessVillageTownController = TextEditingController();
  final TextEditingController _witnessOccupationController = TextEditingController();
  final TextEditingController _witnessSignatureController = TextEditingController();
  final TextEditingController _registrationOfficerNameController = TextEditingController();
  final TextEditingController _registrationOfficerSignatureController = TextEditingController();
  final TextEditingController _applicantSignatureController = TextEditingController();

  // 🔹 Province & District Selection
  final Map<String, List<String>> _provincesWithDistricts = {
    'Central': ['Kairuku-Hiri', 'Rigo', 'Abau'],
    'Eastern Highlands': ['Goroka', 'Henganofi', 'Kainantu', 'Lufa'],
    'East Sepik': ['Angoram', 'Maprik', 'Wosera-Gawi', 'Ambunti-Dreikikir', 'Tambul'],
    'Enga': ['Wabag', 'Lai Valley', 'Kompiam'],
    'Fly River (Western)': ['Middle Fly', 'North Fly', 'South Fly'],
    'Gulf': ['Goilala', 'Kikori', 'Purari'],
    'Madang': ['Adelbert Range', 'Bogia', 'Sumgilbar', 'Sumkar', 'Yuat'],
    'Manus': ['Manus', 'Pasisi'],
    'Milne Bay': ['Doini', 'Fergusson', 'Samarai-Murua', 'Taupota'],
    'Morobe': ['Bulolo', 'Finschhafen', 'Huon', 'Kabwum', 'Lae', 'Markham'],
    'New Ireland': ['Kavieng', 'Namatanai'],
    'Northern (Oro)': ['Baiyer', 'Kairi', 'Koroba-Kopiago', 'Kerema'],
    'North Solomons (Bougainville)': ['Autonomous Region of Bougainville'],
    'Sandaun (West Sepik)': ['Aitape-Lumi', 'Nuku', 'Telefomin', 'West Aitape'],
    'Southern Highlands': ['Mendi-Munihu', 'Nipa-Kutubu', 'Hela', 'Balimo', 'Kandep'],
    'Western Highlands': ['Chimbu', 'Jimi', 'Minj-Manki'],
    'West New Britain': ['Kimbe', 'Kandrian-Gloucester', 'Kou', 'Talasea'],
    'West Sepik': ['Aitape-Lumi', 'Nuku', 'Telefomin', 'West Aitape'],
    'Hela': ['Tari-Anga', 'Komo-Magarima', 'Koroba-Kopiago'],
    'Jiwaka': ['Jimia', 'Angal', 'Purari'],
    'Papua New Guinea Capital District (Port Moresby)': ['National Capital District'],
    'Sandaun': ['Aitape-Lumi', 'Nuku', 'Telefomin', 'West Aitape'],
  };

  List<String> _districts = [];

  // 📸 Face Photo
  File? _facePhoto;
  Uint8List? _facePhotoWeb;  // For web

  // 🖐️ Fingerprint Simulation
  final List<String> _fingers = [
    'Right Thumb',
    'Right Index',
    'Right Middle',
    'Right Ring',
    'Right Little',
    'Left Thumb',
    'Left Index',
    'Left Middle',
    'Left Ring',
    'Left Little',
  ];
  Set<String> _capturedFingers = <String>{};

  // Image picker
  final ImagePicker _picker = ImagePicker();

  // ✅ Loading flag
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedProvince = null;
    _selectedDistrict = null;
    _loadFormData(); // ✅ Load data on startup
  }

  // ✅ Save Form Data to SharedPreferences
  Future<void> _saveFormData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save text fields
    await prefs.setString('reg_day', _regDayController.text);
    await prefs.setString('reg_month', _regMonthController.text);
    await prefs.setString('reg_year', _regYearController.text);

    // Section O fields
    await prefs.setString('province', _provinceController.text);
    await prefs.setString('llg', _llgController.text);
    await prefs.setString('district_office', _districtController.text);
    await prefs.setString('ward', _wardController.text);
    await prefs.setString('reg_point', _regPointController.text);
    await prefs.setString('nid_no', _nidNoController.text);

    await prefs.setString('dob_day', _dobDayController.text);
    await prefs.setString('dob_month', _dobMonthController.text);
    await prefs.setString('dob_year', _dobYearController.text);
    await prefs.setString('birth_cert_entry_no', _birthCertEntryNoController.text);
    await prefs.setString('given_name', _givenNameController.text);
    await prefs.setString('family_name', _familyNameController.text);
    await prefs.setString('mobile_no', _mobileNoController.text);
    await prefs.setString('email_address', _emailAddressController.text);
    await prefs.setString('place_of_birth', _placeOfBirthController.text);
    await prefs.setString('country', _countryController.text);
    await prefs.setString('disability', _disabilityController.text);

    // Mother
    await prefs.setString('mother_nid_no', _motherNidNoController.text);
    await prefs.setString('mother_given_name', _motherGivenNameController.text);
    await prefs.setString('mother_family_name', _motherFamilyNameController.text);
    await prefs.setString('mother_dob', _motherDateOfBirthController.text);
    await prefs.setString('mother_nationality', _motherNationalityController.text);
    await prefs.setString('mother_occupation', _motherOccupationController.text);
    await prefs.setString('mother_denomination', _motherDenominationController.text);
    await prefs.setString('mother_country_origin', _motherCountryOfOriginController.text);
    await prefs.setString('mother_province_state', _motherProvinceStateController.text);
    await prefs.setString('mother_district', _motherDistrictController.text);
    await prefs.setString('mother_llg', _motherLLGController.text);
    await prefs.setString('mother_ward', _motherWardController.text);
    await prefs.setString('mother_village_town', _motherVillageTownController.text);
    await prefs.setString('mother_tribe', _motherTribeController.text);
    await prefs.setString('mother_clan', _motherClanController.text);

    // Father
    await prefs.setString('father_nid_no', _fatherNidNoController.text);
    await prefs.setString('father_given_name', _fatherGivenNameController.text);
    await prefs.setString('father_family_name', _fatherFamilyNameController.text);
    await prefs.setString('father_dob', _fatherDateOfBirthController.text);
    await prefs.setString('father_nationality', _fatherNationalityController.text);
    await prefs.setString('father_occupation', _fatherOccupationController.text);
    await prefs.setString('father_denomination', _fatherDenominationController.text);
    await prefs.setString('father_country_origin', _fatherCountryOfOriginController.text);
    await prefs.setString('father_province_state', _fatherProvinceStateController.text);
    await prefs.setString('father_district', _fatherDistrictController.text);
    await prefs.setString('father_llg', _fatherLLGController.text);
    await prefs.setString('father_ward', _fatherWardController.text);
    await prefs.setString('father_village_town', _fatherVillageTownController.text);
    await prefs.setString('father_tribe', _fatherTribeController.text);
    await prefs.setString('father_clan', _fatherClanController.text);

    // NID Info
    await prefs.setString('province_origin', _provinceOfOriginController.text);
    await prefs.setString('district_origin', _districtOfOriginController.text);
    await prefs.setString('village_town_origin', _villageTownOfOriginController.text);
    await prefs.setString('llg_origin', _llgOfOriginController.text);
    await prefs.setString('ward_origin', _wardOfOriginController.text);
    await prefs.setString('tribe_origin', _tribeOfOriginController.text);
    await prefs.setString('clan_origin', _clanOfOriginController.text);
    await prefs.setString('current_province', _currentProvinceController.text);
    await prefs.setString('current_district', _currentDistrictController.text);
    await prefs.setString('current_village_town', _currentVillageTownController.text);
    await prefs.setString('current_llg', _currentLLGController.text);
    await prefs.setString('current_ward', _currentWardController.text);
    await prefs.setString('spouse_family_name', _spouseFamilyNameController.text);
    await prefs.setString('spouse_nid_no', _spouseNidNoController.text);
    await prefs.setString('occupation', _occupationController.text);
    await prefs.setString('denomination', _denominationController.text);

    // Witness
    await prefs.setString('witness_given_name', _witnessGivenNameController.text);
    await prefs.setString('witness_family_name', _witnessFamilyNameController.text);
    await prefs.setString('witness_nid_no', _witnessNidNoController.text);
    await prefs.setString('witness_province', _witnessProvinceController.text);
    await prefs.setString('witness_llg', _witnessLlgController.text);
    await prefs.setString('witness_district', _witnessDistrictController.text);
    await prefs.setString('witness_ward', _witnessWardController.text);
    await prefs.setString('witness_village_town', _witnessVillageTownController.text);
    await prefs.setString('witness_occupation', _witnessOccupationController.text);
    await prefs.setString('witness_signature', _witnessSignatureController.text);
    await prefs.setString('officer_name', _registrationOfficerNameController.text);
    await prefs.setString('officer_signature', _registrationOfficerSignatureController.text);
    await prefs.setString('applicant_signature', _applicantSignatureController.text);

    // Radio & Dropdown selections
    await prefs.setString('gender', _selectedGender ?? '');
    await prefs.setString('society_type', _societyType ?? '');
    await prefs.setString('marital_status', _maritalStatus ?? '');
    await prefs.setString('education_level', _educationLevel ?? '');
    await prefs.setString('selected_province', _selectedProvince ?? '');
    await prefs.setString('selected_district', _selectedDistrict ?? '');

    // Biometrics: captured fingers
    await prefs.setStringList('captured_fingers', _capturedFingers.toList());

    // Face photo path (if file-based)
    if (_facePhoto != null && !kIsWeb) {
      await prefs.setString('face_photo_path', _facePhoto!.path);
    } else {
      await prefs.remove('face_photo_path');
    }
  }

  // ✅ Load Form Data from SharedPreferences
  Future<void> _loadFormData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load text fields
    _regDayController.text = prefs.getString('reg_day') ?? '';
    _regMonthController.text = prefs.getString('reg_month') ?? '';
    _regYearController.text = prefs.getString('reg_year') ?? '';

    // Section O fields
    _provinceController.text = prefs.getString('province') ?? '';
    _llgController.text = prefs.getString('llg') ?? '';
    _districtController.text = prefs.getString('district_office') ?? '';
    _wardController.text = prefs.getString('ward') ?? '';
    _regPointController.text = prefs.getString('reg_point') ?? '';
    _nidNoController.text = prefs.getString('nid_no') ?? '';

    _dobDayController.text = prefs.getString('dob_day') ?? '';
    _dobMonthController.text = prefs.getString('dob_month') ?? '';
    _dobYearController.text = prefs.getString('dob_year') ?? '';
    _birthCertEntryNoController.text = prefs.getString('birth_cert_entry_no') ?? '';
    _givenNameController.text = prefs.getString('given_name') ?? '';
    _familyNameController.text = prefs.getString('family_name') ?? '';
    _mobileNoController.text = prefs.getString('mobile_no') ?? '';
    _emailAddressController.text = prefs.getString('email_address') ?? '';
    _placeOfBirthController.text = prefs.getString('place_of_birth') ?? '';
    _countryController.text = prefs.getString('country') ?? '';
    _disabilityController.text = prefs.getString('disability') ?? '';

    // Mother
    _motherNidNoController.text = prefs.getString('mother_nid_no') ?? '';
    _motherGivenNameController.text = prefs.getString('mother_given_name') ?? '';
    _motherFamilyNameController.text = prefs.getString('mother_family_name') ?? '';
    _motherDateOfBirthController.text = prefs.getString('mother_dob') ?? '';
    _motherNationalityController.text = prefs.getString('mother_nationality') ?? '';
    _motherOccupationController.text = prefs.getString('mother_occupation') ?? '';
    _motherDenominationController.text = prefs.getString('mother_denomination') ?? '';
    _motherCountryOfOriginController.text = prefs.getString('mother_country_origin') ?? '';
    _motherProvinceStateController.text = prefs.getString('mother_province_state') ?? '';
    _motherDistrictController.text = prefs.getString('mother_district') ?? '';
    _motherLLGController.text = prefs.getString('mother_llg') ?? '';
    _motherWardController.text = prefs.getString('mother_ward') ?? '';
    _motherVillageTownController.text = prefs.getString('mother_village_town') ?? '';
    _motherTribeController.text = prefs.getString('mother_tribe') ?? '';
    _motherClanController.text = prefs.getString('mother_clan') ?? '';

    // Father
    _fatherNidNoController.text = prefs.getString('father_nid_no') ?? '';
    _fatherGivenNameController.text = prefs.getString('father_given_name') ?? '';
    _fatherFamilyNameController.text = prefs.getString('father_family_name') ?? '';
    _fatherDateOfBirthController.text = prefs.getString('father_dob') ?? '';
    _fatherNationalityController.text = prefs.getString('father_nationality') ?? '';
    _fatherOccupationController.text = prefs.getString('father_occupation') ?? '';
    _fatherDenominationController.text = prefs.getString('father_denomination') ?? '';
    _fatherCountryOfOriginController.text = prefs.getString('father_country_origin') ?? '';
    _fatherProvinceStateController.text = prefs.getString('father_province_state') ?? '';
    _fatherDistrictController.text = prefs.getString('father_district') ?? '';
    _fatherLLGController.text = prefs.getString('father_llg') ?? '';
    _fatherWardController.text = prefs.getString('father_ward') ?? '';
    _fatherVillageTownController.text = prefs.getString('father_village_town') ?? '';
    _fatherTribeController.text = prefs.getString('father_tribe') ?? '';
    _fatherClanController.text = prefs.getString('father_clan') ?? '';

    // NID Info
    _provinceOfOriginController.text = prefs.getString('province_origin') ?? '';
    _districtOfOriginController.text = prefs.getString('district_origin') ?? '';
    _villageTownOfOriginController.text = prefs.getString('village_town_origin') ?? '';
    _llgOfOriginController.text = prefs.getString('llg_origin') ?? '';
    _wardOfOriginController.text = prefs.getString('ward_origin') ?? '';
    _tribeOfOriginController.text = prefs.getString('tribe_origin') ?? '';
    _clanOfOriginController.text = prefs.getString('clan_origin') ?? '';
    _currentProvinceController.text = prefs.getString('current_province') ?? '';
    _currentDistrictController.text = prefs.getString('current_district') ?? '';
    _currentVillageTownController.text = prefs.getString('current_village_town') ?? '';
    _currentLLGController.text = prefs.getString('current_llg') ?? '';
    _currentWardController.text = prefs.getString('current_ward') ?? '';
    _spouseFamilyNameController.text = prefs.getString('spouse_family_name') ?? '';
    _spouseNidNoController.text = prefs.getString('spouse_nid_no') ?? '';
    _occupationController.text = prefs.getString('occupation') ?? '';
    _denominationController.text = prefs.getString('denomination') ?? '';

    // Witness
    _witnessGivenNameController.text = prefs.getString('witness_given_name') ?? '';
    _witnessFamilyNameController.text = prefs.getString('witness_family_name') ?? '';
    _witnessNidNoController.text = prefs.getString('witness_nid_no') ?? '';
    _witnessProvinceController.text = prefs.getString('witness_province') ?? '';
    _witnessLlgController.text = prefs.getString('witness_llg') ?? '';
    _witnessDistrictController.text = prefs.getString('witness_district') ?? '';
    _witnessWardController.text = prefs.getString('witness_ward') ?? '';
    _witnessVillageTownController.text = prefs.getString('witness_village_town') ?? '';
    _witnessOccupationController.text = prefs.getString('witness_occupation') ?? '';
    _witnessSignatureController.text = prefs.getString('witness_signature') ?? '';
    _registrationOfficerNameController.text = prefs.getString('officer_name') ?? '';
    _registrationOfficerSignatureController.text = prefs.getString('officer_signature') ?? '';
    _applicantSignatureController.text = prefs.getString('applicant_signature') ?? '';

    // Radio & Dropdown selections
    _selectedGender = prefs.getString('gender');
    _societyType = prefs.getString('society_type');
    _maritalStatus = prefs.getString('marital_status');
    _educationLevel = prefs.getString('education_level');
    _selectedProvince = prefs.getString('selected_province');
    _selectedDistrict = prefs.getString('selected_district');

    // Update districts based on selected province
    if (_selectedProvince != null) {
      _districts = _provincesWithDistricts[_selectedProvince!] ?? [];
    }

    // Biometrics
    final List<String>? savedFingers = prefs.getStringList('captured_fingers');
    if (savedFingers != null) {
      _capturedFingers = Set.from(savedFingers);
    }

    // Load face photo (file only)
    if (!kIsWeb) {
      final String? photoPath = prefs.getString('face_photo_path');
      if (photoPath != null && File(photoPath).existsSync()) {
        setState(() {
          _facePhoto = File(photoPath);
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  // ✅ Clear Form Data
  Future<void> _clearFormData() async {
    final prefs = await SharedPreferences.getInstance();

    // Remove all keys
    await prefs.remove('reg_day');
    await prefs.remove('reg_month');
    await prefs.remove('reg_year');
    await prefs.remove('province');
    await prefs.remove('llg');
    await prefs.remove('district_office');
    await prefs.remove('ward');
    await prefs.remove('reg_point');
    await prefs.remove('nid_no');
    await prefs.remove('dob_day');
    await prefs.remove('dob_month');
    await prefs.remove('dob_year');
    await prefs.remove('birth_cert_entry_no');
    await prefs.remove('given_name');
    await prefs.remove('family_name');
    await prefs.remove('mobile_no');
    await prefs.remove('email_address');
    await prefs.remove('place_of_birth');
    await prefs.remove('country');
    await prefs.remove('disability');
    await prefs.remove('mother_nid_no');
    await prefs.remove('mother_given_name');
    await prefs.remove('mother_family_name');
    await prefs.remove('mother_dob');
    await prefs.remove('mother_nationality');
    await prefs.remove('mother_occupation');
    await prefs.remove('mother_denomination');
    await prefs.remove('mother_country_origin');
    await prefs.remove('mother_province_state');
    await prefs.remove('mother_district');
    await prefs.remove('mother_llg');
    await prefs.remove('mother_ward');
    await prefs.remove('mother_village_town');
    await prefs.remove('mother_tribe');
    await prefs.remove('mother_clan');
    await prefs.remove('father_nid_no');
    await prefs.remove('father_given_name');
    await prefs.remove('father_family_name');
    await prefs.remove('father_dob');
    await prefs.remove('father_nationality');
    await prefs.remove('father_occupation');
    await prefs.remove('father_denomination');
    await prefs.remove('father_country_origin');
    await prefs.remove('father_province_state');
    await prefs.remove('father_district');
    await prefs.remove('father_llg');
    await prefs.remove('father_ward');
    await prefs.remove('father_village_town');
    await prefs.remove('father_tribe');
    await prefs.remove('father_clan');
    await prefs.remove('province_origin');
    await prefs.remove('district_origin');
    await prefs.remove('village_town_origin');
    await prefs.remove('llg_origin');
    await prefs.remove('ward_origin');
    await prefs.remove('tribe_origin');
    await prefs.remove('clan_origin');
    await prefs.remove('current_province');
    await prefs.remove('current_district');
    await prefs.remove('current_village_town');
    await prefs.remove('current_llg');
    await prefs.remove('current_ward');
    await prefs.remove('spouse_family_name');
    await prefs.remove('spouse_nid_no');
    await prefs.remove('occupation');
    await prefs.remove('denomination');
    await prefs.remove('witness_given_name');
    await prefs.remove('witness_family_name');
    await prefs.remove('witness_nid_no');
    await prefs.remove('witness_province');
    await prefs.remove('witness_llg');
    await prefs.remove('witness_district');
    await prefs.remove('witness_ward');
    await prefs.remove('witness_village_town');
    await prefs.remove('witness_occupation');
    await prefs.remove('witness_signature');
    await prefs.remove('officer_name');
    await prefs.remove('officer_signature');
    await prefs.remove('applicant_signature');
    await prefs.remove('gender');
    await prefs.remove('society_type');
    await prefs.remove('marital_status');
    await prefs.remove('education_level');
    await prefs.remove('selected_province');
    await prefs.remove('selected_district');
    await prefs.remove('captured_fingers');
    await prefs.remove('face_photo_path');

    // Clear UI
    _regDayController.clear();
    _regMonthController.clear();
    _regYearController.clear();
    _provinceController.clear();
    _llgController.clear();
    _districtController.clear();
    _wardController.clear();
    _regPointController.clear();
    _nidNoController.clear();
    _dobDayController.clear();
    _dobMonthController.clear();
    _dobYearController.clear();
    _birthCertEntryNoController.clear();
    _givenNameController.clear();
    _familyNameController.clear();
    _mobileNoController.clear();
    _emailAddressController.clear();
    _placeOfBirthController.clear();
    _countryController.clear();
    _disabilityController.clear();
    _motherNidNoController.clear();
    _motherGivenNameController.clear();
    _motherFamilyNameController.clear();
    _motherDateOfBirthController.clear();
    _motherNationalityController.clear();
    _motherOccupationController.clear();
    _motherDenominationController.clear();
    _motherCountryOfOriginController.clear();
    _motherProvinceStateController.clear();
    _motherDistrictController.clear();
    _motherLLGController.clear();
    _motherWardController.clear();
    _motherVillageTownController.clear();
    _motherTribeController.clear();
    _motherClanController.clear();
    _fatherNidNoController.clear();
    _fatherGivenNameController.clear();
    _fatherFamilyNameController.clear();
    _fatherDateOfBirthController.clear();
    _fatherNationalityController.clear();
    _fatherOccupationController.clear();
    _fatherDenominationController.clear();
    _fatherCountryOfOriginController.clear();
    _fatherProvinceStateController.clear();
    _fatherDistrictController.clear();
    _fatherLLGController.clear();
    _fatherWardController.clear();
    _fatherVillageTownController.clear();
    _fatherTribeController.clear();
    _fatherClanController.clear();
    _provinceOfOriginController.clear();
    _districtOfOriginController.clear();
    _villageTownOfOriginController.clear();
    _llgOfOriginController.clear();
    _wardOfOriginController.clear();
    _tribeOfOriginController.clear();
    _clanOfOriginController.clear();
    _currentProvinceController.clear();
    _currentDistrictController.clear();
    _currentVillageTownController.clear();
    _currentLLGController.clear();
    _currentWardController.clear();
    _spouseFamilyNameController.clear();
    _spouseNidNoController.clear();
    _occupationController.clear();
    _denominationController.clear();
    _witnessGivenNameController.clear();
    _witnessFamilyNameController.clear();
    _witnessNidNoController.clear();
    _witnessProvinceController.clear();
    _witnessLlgController.clear();
    _witnessDistrictController.clear();
    _witnessWardController.clear();
    _witnessVillageTownController.clear();
    _witnessOccupationController.clear();
    _witnessSignatureController.clear();
    _registrationOfficerNameController.clear();
    _registrationOfficerSignatureController.clear();
    _applicantSignatureController.clear();

    setState(() {
      _selectedGender = null;
      _societyType = null;
      _maritalStatus = null;
      _educationLevel = null;
      _selectedProvince = null;
      _selectedDistrict = null;
      _districts = [];
      _capturedFingers = {};
      _facePhoto = null;
      _facePhotoWeb = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Form cleared successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "NID Application Form",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.yellowAccent,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.red),
            onPressed: _clearFormData,
            tooltip: "Clear All Form Data",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormHeader(),
              const SizedBox(height: 16),
              _buildOfficeUseSection(),
              const SizedBox(height: 20),
              _buildApplicantDetailsSection(),
              const SizedBox(height: 20),
              _buildParentsDetailsSection(),
              const SizedBox(height: 20),
              _buildNationalIdentityCardSection(),
              const SizedBox(height: 20),
              _buildWitnessDetailsSection(),
              const SizedBox(height: 20),
              _buildBiometricsSection(),
              const SizedBox(height: 30),
              _buildSubmitButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // NEW: Biometrics Section (Face + Fingerprint)
  Widget _buildBiometricsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "E. Biometric Data Collection",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        _buildFacePhotoSection(),
        const SizedBox(height: 20),
        _buildFingerprintSection(),
      ],
    );
  }

  Widget _buildFacePhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upload Face Photo (ID Size)",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 120,
          height: 120,
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[100],
              ),
              child: _facePhoto == null && _facePhotoWeb == null
                  ? const Center(
                child: Text(
                  "No photo\nselected",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                ),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    ? Image.memory(
                  _facePhotoWeb!,
                  fit: BoxFit.cover,
                )
                    : Image.file(
                  _facePhoto!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () => _pickFacePhoto(ImageSource.camera),
          icon: const Icon(Icons.camera_alt, size: 18),
          label: const Text("Take Face Photo"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () => _pickFacePhoto(ImageSource.gallery),
          icon: const Icon(Icons.photo, size: 18),
          label: const Text("Choose from Gallery"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFacePhoto(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(
      source: source,
      maxHeight: 600,
      maxWidth: 600,
      imageQuality: 70,
    );
    if (photo != null) {
      if (kIsWeb) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _facePhotoWeb = bytes;
          _facePhoto = null;
        });
      } else {
        setState(() {
          _facePhoto = File(photo.path);
          _facePhotoWeb = null;
        });
      }
      await _saveFormData(); // ✅ Auto-save after picking photo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            source == ImageSource.camera
                ? "Face photo captured!"
                : "Photo selected from gallery!",
          ),
        ),
      );
    }
  }

  Widget _buildFingerprintSection() {
    final int capturedCount = _capturedFingers.length;
    final double progress = capturedCount / _fingers.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Fingerprint Registration (10 fingers)",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          color: progress == 1.0 ? Colors.green : Colors.blue,
        ),
        const SizedBox(height: 4),
        Text(
          "$capturedCount / 10 fingers captured",
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _fingers.map((finger) {
            final captured = _capturedFingers.contains(finger);
            return ActionChip(
              label: Text(finger.split(' ').last),
              avatar: Icon(
                captured ? Icons.fingerprint : Icons.fingerprint_outlined,
                color: captured ? Colors.green : Colors.grey,
                size: 18,
              ),
              backgroundColor: captured ? Colors.green[50] : Colors.grey[100],
              onPressed: () => _captureFingerprint(finger),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Capturing all 10 fingerprints...")),
            );
            Future.delayed(const Duration(seconds: 2), () {
              setState(() {
                _capturedFingers = Set.from(_fingers);
              });
              _saveFormData(); // ✅ Save after capture
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ All 10 fingerprints captured!")),
              );
            });
          },
          icon: const Icon(Icons.auto_fix_high, size: 18),
          label: const Text("Capture All"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _captureFingerprint(String finger) async {
    if (_capturedFingers.contains(finger)) {
      setState(() {
        _capturedFingers.remove(finger);
      });
      await _saveFormData(); // ✅ Save after removing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$finger removed.")),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text("Scanning..."),
            ],
          ),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
      setState(() {
        _capturedFingers.add(finger);
      });
      await _saveFormData(); // ✅ Save after capturing
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$finger captured!")),
      );
    }
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

  Widget _buildOfficeUseSection() {
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
              _buildSmallField("DD", controller: _regDayController, validate: false),
              const Text(" - "),
              _buildSmallField("MM", controller: _regMonthController, validate: false),
              const Text(" - "),
              _buildSmallField("YYYY", controller: _regYearController, validate: false),
            ],
          ),
        ),
        _buildTwoFields(
          leftLabel: "Province:",
          leftField: _buildMediumField("Enter Province", controller: _provinceController, validate: false),
          rightLabel: "LLG:",
          rightField: _buildSmallField("LLG", controller: _llgController, validate: false),
        ),
        _buildTwoFields(
          leftLabel: "District:",
          leftField: _buildMediumField("Enter District", controller: _districtController, validate: false),
          rightLabel: "Ward:",
          rightField: _buildSmallField("Ward", controller: _wardController, validate: false),
        ),
        _buildTwoFields(
          leftLabel: "Registration Point:",
          leftField: _buildMediumField("Enter Point", controller: _regPointController, validate: false),
          rightLabel: "NID No:",
          rightField: _buildSmallField("NID", controller: _nidNoController, validate: false),
        ),
        _buildRowField(
          label: "Registration Officer's Name:",
          child: _buildWideField("Enter Officer's Name", controller: _registrationOfficerNameController, validate: false),
        ),
      ],
    );
  }

  Widget _buildApplicantDetailsSection() {
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
        const SizedBox(height: 4),
        const Text(
          "PLEASE WRITE IN BLOCK LETTERS & FILL UP ALL REQUIRED INFORMATION (*)",
          style: TextStyle(
            fontSize: 10,
            fontStyle: FontStyle.italic,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 12),
        _buildTwoFields(
          leftLabel: "*Birth Cert Entry No:",
          leftField: _buildWideField("Enter Number", controller: _birthCertEntryNoController),
          rightLabel: "*Date of Birth:",
          rightField: Row(
            children: [
              _buildSmallField("DD", controller: _dobDayController),
              const Text(" - "),
              _buildSmallField("MM", controller: _dobMonthController),
              const Text(" - "),
              _buildSmallField("YYYY", controller: _dobYearController),
            ],
          ),
        ),
        _buildRowField(
          label: "*Given Name(s):",
          child: _buildWideField("Enter Given Name(s)", controller: _givenNameController),
        ),
        _buildRowField(
          label: "*Family Name:",
          child: _buildWideField("Enter Family Name", controller: _familyNameController),
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
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                        _saveFormData(); // ✅ Save on change
                      });
                    },
                  ),
                  const Text("Male", style: TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  Radio<String>(
                    value: "Female",
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                        _saveFormData(); // ✅ Save on change
                      });
                    },
                  ),
                  const Text("Female", style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
        _buildRowField(
          label: "*Mobile No:",
          child: _buildWideField("Enter Mobile Number", controller: _mobileNoController),
        ),
        _buildRowField(
          label: "Email Address:",
          child: _buildWideField("Enter Email (Optional)", controller: _emailAddressController),
        ),
        _buildRowField(
          label: "Place of Birth:",
          child: _buildWideField("Enter Place of Birth", controller: _placeOfBirthController),
        ),
        _buildRowField(
          label: "*Country:",
          child: _buildWideField("Enter Country", controller: _countryController),
        ),
        _buildRowField(
          label: "*Province/State:",
          child: DropdownButtonFormField<String>(
            value: _selectedProvince,
            hint: const Text("Select Province"),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            items: _provincesWithDistricts.keys
                .map((province) => DropdownMenuItem(value: province, child: Text(province)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedProvince = value;
                _selectedDistrict = null;
                _districts = _provincesWithDistricts[value] ?? [];
                _saveFormData(); // ✅ Save on change
              });
            },
            validator: (value) => value == null ? "Province is required" : null,
          ),
        ),
        _buildRowField(
          label: "*District:",
          child: DropdownButtonFormField<String>(
            value: _selectedDistrict,
            hint: const Text("Select District"),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            items: _districts
                .map((district) => DropdownMenuItem(value: district, child: Text(district)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedDistrict = value;
                _saveFormData(); // ✅ Save on change
              });
            },
            validator: (value) => value == null ? "District is required" : null,
          ),
        ),
        _buildRowField(
          label: "Disability:",
          child: _buildWideField("Specify if any", controller: _disabilityController),
        ),
      ],
    );
  }

  Widget _buildParentsDetailsSection() {
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("MOTHER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  _buildRowField(
                    label: "NID No:",
                    child: _buildWideField("Enter NID No", controller: _motherNidNoController),
                  ),
                  _buildRowField(
                    label: "*Given Name(s):",
                    child: _buildWideField("Enter Given Name(s)", controller: _motherGivenNameController),
                  ),
                  _buildRowField(
                    label: "*Family Name:",
                    child: _buildWideField("Enter Family Name", controller: _motherFamilyNameController),
                  ),
                  _buildRowField(
                    label: "*Date of Birth:",
                    child: Row(
                      children: [
                        _buildSmallField("DD", controller: _motherDateOfBirthController),
                        const Text(" - "),
                        _buildSmallField("MM", controller: _motherDateOfBirthController),
                        const Text(" - "),
                        _buildSmallField("YYYY", controller: _motherDateOfBirthController),
                      ],
                    ),
                  ),
                  _buildRowField(
                    label: "*Nationality:",
                    child: _buildWideField("Enter Nationality", controller: _motherNationalityController),
                  ),
                  _buildRowField(
                    label: "*Occupation:",
                    child: _buildWideField("Enter Occupation", controller: _motherOccupationController),
                  ),
                  _buildRowField(
                    label: "*Denomination:",
                    child: _buildWideField("Enter Denomination", controller: _motherDenominationController),
                  ),
                  const Text("Place of Origin:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  _buildRowField(
                    label: "*Country:",
                    child: _buildWideField("Enter Country", controller: _motherCountryOfOriginController),
                  ),
                  _buildRowField(
                    label: "*Province/State:",
                    child: _buildWideField("Enter Province/State", controller: _motherProvinceStateController),
                  ),
                  _buildRowField(
                    label: "*District:",
                    child: _buildWideField("Enter District", controller: _motherDistrictController),
                  ),
                  _buildRowField(
                    label: "*LLG:",
                    child: _buildWideField("Enter LLG", controller: _motherLLGController),
                  ),
                  _buildRowField(
                    label: "*Ward:",
                    child: _buildWideField("Enter Ward", controller: _motherWardController),
                  ),
                  _buildRowField(
                    label: "*Village/Town:",
                    child: _buildWideField("Enter Village/Town", controller: _motherVillageTownController),
                  ),
                  _buildRowField(
                    label: "*Tribe:",
                    child: _buildWideField("Enter Tribe", controller: _motherTribeController),
                  ),
                  _buildRowField(
                    label: "*Clan:",
                    child: _buildWideField("Enter Clan", controller: _motherClanController),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("FATHER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  _buildRowField(
                    label: "NID No:",
                    child: _buildWideField("Enter NID No", controller: _fatherNidNoController),
                  ),
                  _buildRowField(
                    label: "*Given Name(s):",
                    child: _buildWideField("Enter Given Name(s)", controller: _fatherGivenNameController),
                  ),
                  _buildRowField(
                    label: "*Family Name:",
                    child: _buildWideField("Enter Family Name", controller: _fatherFamilyNameController),
                  ),
                  _buildRowField(
                    label: "*Date of Birth:",
                    child: Row(
                      children: [
                        _buildSmallField("DD", controller: _fatherDateOfBirthController),
                        const Text(" - "),
                        _buildSmallField("MM", controller: _fatherDateOfBirthController),
                        const Text(" - "),
                        _buildSmallField("YYYY", controller: _fatherDateOfBirthController),
                      ],
                    ),
                  ),
                  _buildRowField(
                    label: "*Nationality:",
                    child: _buildWideField("Enter Nationality", controller: _fatherNationalityController),
                  ),
                  _buildRowField(
                    label: "*Occupation:",
                    child: _buildWideField("Enter Occupation", controller: _fatherOccupationController),
                  ),
                  _buildRowField(
                    label: "*Denomination:",
                    child: _buildWideField("Enter Denomination", controller: _fatherDenominationController),
                  ),
                  const Text("Place of Origin:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 8),
                  _buildRowField(
                    label: "*Country:",
                    child: _buildWideField("Enter Country", controller: _fatherCountryOfOriginController),
                  ),
                  _buildRowField(
                    label: "*Province/State:",
                    child: _buildWideField("Enter Province/State", controller: _fatherProvinceStateController),
                  ),
                  _buildRowField(
                    label: "*District:",
                    child: _buildWideField("Enter District", controller: _fatherDistrictController),
                  ),
                  _buildRowField(
                    label: "*LLG:",
                    child: _buildWideField("Enter LLG", controller: _fatherLLGController),
                  ),
                  _buildRowField(
                    label: "*Ward:",
                    child: _buildWideField("Enter Ward", controller: _fatherWardController),
                  ),
                  _buildRowField(
                    label: "*Village/Town:",
                    child: _buildWideField("Enter Village/Town", controller: _fatherVillageTownController),
                  ),
                  _buildRowField(
                    label: "*Tribe:",
                    child: _buildWideField("Enter Tribe", controller: _fatherTribeController),
                  ),
                  _buildRowField(
                    label: "*Clan:",
                    child: _buildWideField("Enter Clan", controller: _fatherClanController),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNationalIdentityCardSection() {
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
        const SizedBox(height: 4),
        const Text(
          "THIS SECTION IS TO BE COMPLETED BY APPLICANTS 18 YEARS AND ABOVE ONLY",
          style: TextStyle(
            fontSize: 10,
            fontStyle: FontStyle.italic,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 12),
        const Text("Place of Origin:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        _buildTwoFields(
          leftLabel: "*Province:",
          leftField: _buildWideField("Enter Province", controller: _provinceOfOriginController),
          rightLabel: "*LLG:",
          rightField: _buildWideField("Enter LLG", controller: _llgOfOriginController),
        ),
        _buildTwoFields(
          leftLabel: "*District:",
          leftField: _buildWideField("Enter District", controller: _districtOfOriginController),
          rightLabel: "*Ward:",
          rightField: _buildWideField("Enter Ward", controller: _wardOfOriginController),
        ),
        _buildTwoFields(
          leftLabel: "*Village/Town:",
          leftField: _buildWideField("Enter Village/Town", controller: _villageTownOfOriginController),
          rightLabel: "*Tribe:",
          rightField: _buildWideField("Enter Tribe", controller: _tribeOfOriginController),
        ),
        _buildTwoFields(
          leftLabel: "*Clan:",
          leftField: _buildWideField("Enter Clan", controller: _clanOfOriginController),
          rightLabel: "",
          rightField: const SizedBox(),
        ),
        _buildRowField(
          label: "*Society:",
          child: Row(
            children: [
              Row(
                children: [
                  Radio<String>(
                    value: "Patrilineal",
                    groupValue: _societyType,
                    onChanged: (value) {
                      setState(() {
                        _societyType = value;
                        _saveFormData(); // ✅ Save on change
                      });
                    },
                  ),
                  const Text("Patrilineal", style: TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  Radio<String>(
                    value: "Matrilineal",
                    groupValue: _societyType,
                    onChanged: (value) {
                      setState(() {
                        _societyType = value;
                        _saveFormData(); // ✅ Save on change
                      });
                    },
                  ),
                  const Text("Matrilineal", style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text("Current Residential Address:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        _buildTwoFields(
          leftLabel: "*Province:",
          leftField: _buildWideField("Enter Province", controller: _currentProvinceController),
          rightLabel: "*LLG:",
          rightField: _buildWideField("Enter LLG", controller: _currentLLGController),
        ),
        _buildTwoFields(
          leftLabel: "*District:",
          leftField: _buildWideField("Enter District", controller: _currentDistrictController),
          rightLabel: "*Ward:",
          rightField: _buildWideField("Enter Ward", controller: _currentWardController),
        ),
        _buildRowField(
          label: "*Village/Town:",
          child: _buildWideField("Enter Village/Town", controller: _currentVillageTownController),
        ),
        const SizedBox(height: 12),
        const Text("*Marital Status:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Radio<String>(
                  value: "Never Married",
                  groupValue: _maritalStatus,
                  onChanged: (value) {
                    setState(() {
                      _maritalStatus = value;
                      _saveFormData(); // ✅ Save on change
                    });
                  },
                ),
                const Text("Never Married", style: TextStyle(fontSize: 12)),
              ],
            ),
            Row(
              children: [
                Radio<String>(
                  value: "Married",
                  groupValue: _maritalStatus,
                  onChanged: (value) {
                    setState(() {
                      _maritalStatus = value;
                      _saveFormData(); // ✅ Save on change
                    });
                  },
                ),
                const Text("Married", style: TextStyle(fontSize: 12)),
              ],
            ),
            Row(
              children: [
                Radio<String>(
                  value: "Separated",
                  groupValue: _maritalStatus,
                  onChanged: (value) {
                    setState(() {
                      _maritalStatus = value;
                      _saveFormData(); // ✅ Save on change
                    });
                  },
                ),
                const Text("Separated", style: TextStyle(fontSize: 12)),
              ],
            ),
            Row(
              children: [
                Radio<String>(
                  value: "Divorced",
                  groupValue: _maritalStatus,
                  onChanged: (value) {
                    setState(() {
                      _maritalStatus = value;
                      _saveFormData(); // ✅ Save on change
                    });
                  },
                ),
                const Text("Divorced", style: TextStyle(fontSize: 12)),
              ],
            ),
            Row(
              children: [
                Radio<String>(
                  value: "Widow/Widower",
                  groupValue: _maritalStatus,
                  onChanged: (value) {
                    setState(() {
                      _maritalStatus = value;
                      _saveFormData(); // ✅ Save on change
                    });
                  },
                ),
                const Text("Widow/Widower", style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildRowField(
          label: "Preferred Spouse Family Name:",
          child: _buildWideField("Enter Spouse Family Name", controller: _spouseFamilyNameController),
        ),
        _buildRowField(
          label: "Spouse NID No/Name:",
          child: _buildWideField("Enter Spouse NID No or Name", controller: _spouseNidNoController),
        ),
        const SizedBox(height: 12),
        const Text("*Education:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Radio<String>(
                  value: "Never Attended School",
                  groupValue: _educationLevel,
                  onChanged: (value) {
                    setState(() {
                      _educationLevel = value;
                      _saveFormData(); // ✅ Save on change
                    });
                  },
                ),
                const Text("Never Attended School", style: TextStyle(fontSize: 12)),
              ],
            ),
            Row(
              children: [
                Radio<String>(
                  value: "Elementary",
                  groupValue: _educationLevel,
                  onChanged: (value) {
                    setState(() {
                      _educationLevel = value;
                      _saveFormData(); // ✅ Save on change
                    });
                  },
                ),
                const Text("Elementary", style: TextStyle(fontSize: 12)),
              ],
            ),
            Row(
              children: [
                Radio<String>(
                  value: "Primary",
                  groupValue: _educationLevel,
                  onChanged: (value) {
                    setState(() {
                      _educationLevel = value;
                      _saveFormData(); // ✅ Save on change
                    });
                  },
                ),
                const Text("Primary", style: TextStyle(fontSize: 12)),
              ],
            ),
            Row(
              children: [
                Radio<String>(
                  value: "Secondary",
                  groupValue: _educationLevel,
                  onChanged: (value) {
                    setState(() {
                      _educationLevel = value;
                      _saveFormData(); // ✅ Save on change
                    });
                  },
                ),
                const Text("Secondary", style: TextStyle(fontSize: 12)),
              ],
            ),
            Row(
              children: [
                Radio<String>(
                  value: "Tertiary",
                  groupValue: _educationLevel,
                  onChanged: (value) {
                    setState(() {
                      _educationLevel = value;
                      _saveFormData(); // ✅ Save on change
                    });
                  },
                ),
                const Text("Tertiary", style: TextStyle(fontSize: 12)),
              ],
            ),
            Row(
              children: [
                Radio<String>(
                  value: "Others",
                  groupValue: _educationLevel,
                  onChanged: (value) {
                    setState(() {
                      _educationLevel = value;
                      _saveFormData(); // ✅ Save on change
                    });
                  },
                ),
                const Text("Others", style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        _buildRowField(
          label: "*Occupation:",
          child: _buildWideField("Enter Occupation", controller: _occupationController),
        ),
        _buildRowField(
          label: "*Denomination:",
          child: _buildWideField("Enter Denomination", controller: _denominationController),
        ),
      ],
    );
  }

  Widget _buildWitnessDetailsSection() {
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
        const SizedBox(height: 4),
        const Text(
          "AUTHORIZED WITNESS ONLY - COUNCILLOR, PASTOR, CLAN LEADER, HEALTH WORKER, PROFESSIONALS",
          style: TextStyle(
            fontSize: 9,
            fontStyle: FontStyle.italic,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 12),
        _buildTwoFields(
          leftLabel: "*Given Name(s):",
          leftField: _buildWideField("Enter Given Name(s)", controller: _witnessGivenNameController),
          rightLabel: "NID No:",
          rightField: _buildWideField("Enter NID No", controller: _witnessNidNoController),
        ),
        _buildRowField(
          label: "*Family Name:",
          child: _buildWideField("Enter Family Name", controller: _witnessFamilyNameController),
        ),
        const SizedBox(height: 12),
        const Text("Current Residential Address:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        _buildTwoFields(
          leftLabel: "*Province:",
          leftField: _buildWideField("Enter Province", controller: _witnessProvinceController),
          rightLabel: "*LLG:",
          rightField: _buildWideField("Enter LLG", controller: _witnessLlgController),
        ),
        _buildTwoFields(
          leftLabel: "*District:",
          leftField: _buildWideField("Enter District", controller: _witnessDistrictController),
          rightLabel: "*Ward:",
          rightField: _buildWideField("Enter Ward", controller: _witnessWardController),
        ),
        _buildTwoFields(
          leftLabel: "*Village/Town:",
          leftField: _buildWideField("Enter Village/Town", controller: _witnessVillageTownController),
          rightLabel: "*Signature:",
          rightField: _buildWideField("Enter Signature", controller: _witnessSignatureController),
        ),
        _buildRowField(
          label: "*Occupation:",
          child: _buildWideField("Enter Occupation", controller: _witnessOccupationController),
        ),
        const SizedBox(height: 12),
        const Text(
          "I hereby certify that the above information is correct for the purpose of registration under the Civil Registration Act (Chapter 304) Amended 2014",
          style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildRowField(
                label: "*Registration Officer's Signature:",
                child: _buildWideField("Enter Signature", controller: _registrationOfficerSignatureController),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: _buildRowField(
                label: "*Applicant's Signature/Mark:",
                child: _buildWideField("Enter Signature/Mark", controller: _applicantSignatureController),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: Container(
        width: 250,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50),
              Color(0xFF2E7D32),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green[800]!.withOpacity(0.6),
              blurRadius: 4,
              offset: Offset(0, 6),
              spreadRadius: 0,
            ),
            const BoxShadow(
              color: Color(0xFF81C784),
              blurRadius: 4,
              offset: Offset(0, -2),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              await _submitForm();
            }
          },
          child: const Text(
            "Submit Application",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black45,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    final int user_id = 1;
    final List<String> capturedFingers = _capturedFingers.toList();
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApplyFormPage.apiUrl),
      );

      final Map<String, dynamic> formData = {
        "user_id": user_id,
        "registration_date": {
          "day": _regDayController.text,
          "month": _regMonthController.text,
          "year": _regYearController.text,
        },
        "province": _provinceController.text,
        "llg": _llgController.text,
        "district": _districtController.text,
        "ward": _wardController.text,
        "registration_point": _regPointController.text,
        "nid_no": _nidNoController.text,
        "officer_name": _registrationOfficerNameController.text,
        "birth_cert_entry_no": _birthCertEntryNoController.text,
        "given_names": _givenNameController.text,
        "family_name": _familyNameController.text,
        "gender": _selectedGender,
        "mobile_no": _mobileNoController.text,
        "email": _emailAddressController.text,
        "place_of_birth": _placeOfBirthController.text,
        "country": _countryController.text,
        "province_state": _selectedProvince,
        "district": _selectedDistrict,
        "disability": _disabilityController.text,
        "date_of_birth": {
          "day": _dobDayController.text,
          "month": _dobMonthController.text,
          "year": _dobYearController.text,
        },
        // Mother
        "mother": {
          "nid_no": _motherNidNoController.text,
          "given_names": _motherGivenNameController.text,
          "family_name": _motherFamilyNameController.text,
          "date_of_birth": _motherDateOfBirthController.text,
          "nationality": _motherNationalityController.text,
          "occupation": _motherOccupationController.text,
          "denomination": _motherDenominationController.text,
          "country_of_origin": _motherCountryOfOriginController.text,
          "province_state": _motherProvinceStateController.text,
          "district": _motherDistrictController.text,
          "llg": _motherLLGController.text,
          "ward": _motherWardController.text,
          "village_town": _motherVillageTownController.text,
          "tribe": _motherTribeController.text,
          "clan": _motherClanController.text,
        },
        // Father
        "father": {
          "nid_no": _fatherNidNoController.text,
          "given_names": _fatherGivenNameController.text,
          "family_name": _fatherFamilyNameController.text,
          "date_of_birth": _fatherDateOfBirthController.text,
          "nationality": _fatherNationalityController.text,
          "occupation": _fatherOccupationController.text,
          "denomination": _fatherDenominationController.text,
          "country_of_origin": _fatherCountryOfOriginController.text,
          "province_state": _fatherProvinceStateController.text,
          "district": _fatherDistrictController.text,
          "llg": _fatherLLGController.text,
          "ward": _fatherWardController.text,
          "village_town": _fatherVillageTownController.text,
          "tribe": _fatherTribeController.text,
          "clan": _fatherClanController.text,
        },
        // NID Info
        "nid_info": {
          "place_of_origin": {
            "province": _provinceOfOriginController.text,
            "district": _districtOfOriginController.text,
            "village_town": _villageTownOfOriginController.text,
            "llg": _llgOfOriginController.text,
            "ward": _wardOfOriginController.text,
            "tribe": _tribeOfOriginController.text,
            "clan": _clanOfOriginController.text,
            "society": _societyType,
          },
          "current_address": {
            "province": _currentProvinceController.text,
            "district": _currentDistrictController.text,
            "village_town": _currentVillageTownController.text,
            "llg": _currentLLGController.text,
            "ward": _currentWardController.text,
          },
          "marital_status": _maritalStatus,
          "spouse_family_name": _spouseFamilyNameController.text,
          "spouse_nid_no": _spouseNidNoController.text,
          "education": _educationLevel,
          "occupation": _occupationController.text,
          "denomination": _denominationController.text,
        },
        // Witness
        "witness": {
          "given_names": _witnessGivenNameController.text,
          "family_name": _witnessFamilyNameController.text,
          "nid_no": _witnessNidNoController.text,
          "current_address": {
            "province": _witnessProvinceController.text,
            "district": _witnessDistrictController.text,
            "ward": _witnessWardController.text,
            "llg": _witnessLlgController.text,
            "village_town": _witnessVillageTownController.text,
          },
          "occupation": _witnessOccupationController.text,
          "signature": _witnessSignatureController.text,
        },
        // Signatures
        "signatures": {
          "applicant": _applicantSignatureController.text,
        },
        // Biometrics
        "biometrics": {
          "fingerprint_status": {
            "total_fingers": 10,
            "captured_count": capturedFingers.length,
            "captured_fingers": capturedFingers,
            "all_captured": capturedFingers.length == 10,
          }
        }
      };

      request.fields['data'] = jsonEncode(formData);

      if (_facePhoto != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'face_photo',
          _facePhoto!.path,
          filename: 'face_photo.jpg',
        ));
      } else if (_facePhotoWeb != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'face_photo',
          _facePhotoWeb!,
          filename: 'face_photo.jpg',
        ));
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Application submitted successfully!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        final responseBody = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error: ${response.statusCode} - $responseBody"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Network error: $e"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  // Helper Widgets
  Widget _buildWideField(
      String hint, {
        required TextEditingController controller,
        bool validate = true,
      }) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
        ),
        validator: validate
            ? (value) {
          if (value == null || value.isEmpty) return "This field is required";
          return null;
        }
            : null,
        onChanged: (_) => _saveFormData(), // ✅ Auto-save on change
      ),
    );
  }

  Widget _buildSmallField(
      String hint, {
        required TextEditingController controller,
        bool validate = true,
      }) {
    return SizedBox(
      width: 60,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          isDense: true,
        ),
        validator: validate
            ? (value) {
          if (value == null || value.isEmpty) return "Required";
          return null;
        }
            : null,
        onChanged: (_) => _saveFormData(), // ✅ Auto-save on change
      ),
    );
  }

  Widget _buildMediumField(
      String hint, {
        required TextEditingController controller,
        bool validate = true,
      }) {
    return SizedBox(
      width: 180,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
        ),
        validator: validate
            ? (value) {
          if (value == null || value.isEmpty) return "Required";
          return null;
        }
            : null,
        onChanged: (_) => _saveFormData(), // ✅ Auto-save on change
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

  @override
  void dispose() {
    // Dispose all controllers
    _regDayController.dispose();
    _regMonthController.dispose();
    _regYearController.dispose();
    _provinceController.dispose();
    _llgController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _regPointController.dispose();
    _nidNoController.dispose();
    _dobDayController.dispose();
    _dobMonthController.dispose();
    _dobYearController.dispose();
    _birthCertEntryNoController.dispose();
    _givenNameController.dispose();
    _familyNameController.dispose();
    _mobileNoController.dispose();
    _emailAddressController.dispose();
    _placeOfBirthController.dispose();
    _countryController.dispose();
    _disabilityController.dispose();
    _motherNidNoController.dispose();
    _motherGivenNameController.dispose();
    _motherFamilyNameController.dispose();
    _motherDateOfBirthController.dispose();
    _motherNationalityController.dispose();
    _motherOccupationController.dispose();
    _motherDenominationController.dispose();
    _motherCountryOfOriginController.dispose();
    _motherProvinceStateController.dispose();
    _motherDistrictController.dispose();
    _motherLLGController.dispose();
    _motherWardController.dispose();
    _motherVillageTownController.dispose();
    _motherTribeController.dispose();
    _motherClanController.dispose();
    _fatherNidNoController.dispose();
    _fatherGivenNameController.dispose();
    _fatherFamilyNameController.dispose();
    _fatherDateOfBirthController.dispose();
    _fatherNationalityController.dispose();
    _fatherOccupationController.dispose();
    _fatherDenominationController.dispose();
    _fatherCountryOfOriginController.dispose();
    _fatherProvinceStateController.dispose();
    _fatherDistrictController.dispose();
    _fatherLLGController.dispose();
    _fatherWardController.dispose();
    _fatherVillageTownController.dispose();
    _fatherTribeController.dispose();
    _fatherClanController.dispose();
    _marriageCountryController.dispose();
    _marriageProvinceStateController.dispose();
    _marriageDateDayController.dispose();
    _marriageDateMonthController.dispose();
    _marriageDateYearController.dispose();
    _marriageRegNoController.dispose();
    _provinceOfOriginController.dispose();
    _districtOfOriginController.dispose();
    _villageTownOfOriginController.dispose();
    _llgOfOriginController.dispose();
    _wardOfOriginController.dispose();
    _tribeOfOriginController.dispose();
    _clanOfOriginController.dispose();
    _currentProvinceController.dispose();
    _currentDistrictController.dispose();
    _currentVillageTownController.dispose();
    _currentLLGController.dispose();
    _currentWardController.dispose();
    _spouseFamilyNameController.dispose();
    _spouseNidNoController.dispose();
    _occupationController.dispose();
    _denominationController.dispose();
    _witnessGivenNameController.dispose();
    _witnessFamilyNameController.dispose();
    _witnessNidNoController.dispose();
    _witnessProvinceController.dispose();
    _witnessLlgController.dispose();
    _witnessDistrictController.dispose();
    _witnessWardController.dispose();
    _witnessVillageTownController.dispose();
    _witnessOccupationController.dispose();
    _witnessSignatureController.dispose();
    _registrationOfficerNameController.dispose();
    _registrationOfficerSignatureController.dispose();
    _applicantSignatureController.dispose();
    super.dispose();
  }
}