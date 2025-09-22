import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_view_model.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String selectedRole = 'user';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  double _passwordStrength = 0;

  final _givenNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_calculatePasswordStrength);
  }

  @override
  void dispose() {
    _givenNameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _calculatePasswordStrength() {
    String password = _passwordController.text;
    double strength = 0;

    if (password.length >= 8) strength += 0.3;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.1;

    setState(() {
      _passwordStrength = strength.clamp(0.0, 1.0);
    });
  }

  Color _getStrengthColor() {
    if (_passwordStrength < 0.3) return Colors.red;
    if (_passwordStrength < 0.6) return Colors.orange;
    return Colors.green;
  }

  String _getStrengthText() {
    if (_passwordStrength < 0.3) return 'Weak';
    if (_passwordStrength < 0.6) return 'Medium';
    return 'Strong';
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      _showErrorDialog("Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);

      bool success = await authVM.register(
        _givenNameController.text.trim(),
        _surnameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        selectedRole,
      );

      if (success && mounted) {
        _showSuccessDialog("Account Created", "You can now login.");
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Signup Failed"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("Continue"),
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to login page
            },
          )
        ],
      ),
    );
  }

  Widget _buildTextField(IconData icon, String label,
      {bool isPassword = false, required TextEditingController controller}) {
    return SizedBox(
      width: 280,
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? (label == 'Password' ? _obscurePassword : _obscureConfirmPassword) : false,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.deepPurple),
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          suffixIcon: isPassword ? IconButton(
            icon: Icon(
              (label == 'Password' ? _obscurePassword : _obscureConfirmPassword)
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.deepPurple,
            ),
            onPressed: () {
              setState(() {
                if (label == 'Password') {
                  _obscurePassword = !_obscurePassword;
                } else {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                }
              });
            },
          ) : null,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          if (label == 'Email' &&
              !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
            return 'Enter a valid email';
          }
          if (label == 'Password' && value.length < 8) {
            return 'Password must be at least 8 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: _passwordStrength,
            backgroundColor: Colors.grey[300],
            color: _getStrengthColor(),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 4),
          Text(
            'Password strength: ${_getStrengthText()}',
            style: TextStyle(
              fontSize: 12,
              color: _getStrengthColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return SizedBox(
      width: 280,
      child: DropdownButtonFormField<String>(
        value: selectedRole,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.account_circle, color: Colors.deepPurple),
          labelText: 'Select Role',
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        items: ['user', 'admin'].map((role) {
          return DropdownMenuItem(value: role, child: Text(role));
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedRole = value!;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/mynid_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Scrollable Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: SizedBox(
                width: 350,
                child: Card(
                  color: Colors.white.withOpacity(0.65),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 12,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Register to use MyNID',
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(height: 24),

                          // Given Name
                          _buildTextField(
                            Icons.person_outline,
                            'Given Name',
                            controller: _givenNameController,
                          ),
                          const SizedBox(height: 16),

                          // Surname
                          _buildTextField(
                            Icons.person_outline,
                            'Surname',
                            controller: _surnameController,
                          ),
                          const SizedBox(height: 16),

                          // Email
                          _buildTextField(
                            Icons.email,
                            'Email',
                            controller: _emailController,
                          ),
                          const SizedBox(height: 16),

                          // Password
                          _buildTextField(
                            Icons.lock,
                            'Password',
                            isPassword: true,
                            controller: _passwordController,
                          ),
                          const SizedBox(height: 8),
                          _buildPasswordStrengthIndicator(),
                          const SizedBox(height: 8),

                          // Confirm Password
                          _buildTextField(
                            Icons.lock_outline,
                            'Confirm Password',
                            isPassword: true,
                            controller: _confirmPasswordController,
                          ),
                          const SizedBox(height: 16),

                          // Role Dropdown
                          _buildRoleDropdown(),
                          const SizedBox(height: 24),

                          // Sign Up Button
                          _isLoading
                              ? const CircularProgressIndicator(color: Colors.deepPurple)
                              : SizedBox(
                            width: 280,
                            child: ElevatedButton(
                              onPressed: _handleSignup,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                backgroundColor: Colors.deepPurple,
                                elevation: 8,
                                shadowColor: Colors.deepPurpleAccent,
                              ),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Login Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account? "),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Copyright
                          const Text(
                            "© 2025 MyNID PNG",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}