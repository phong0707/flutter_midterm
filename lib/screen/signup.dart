import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_application_1/app_url.dart';
import 'package:mobile_application_1/screen/login.dart';
import 'package:http/http.dart' as http;

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool isPassword = true;
  bool isConfirmPassword = true;

  final TextEditingController txtUserName = TextEditingController();
  final TextEditingController txtFullName = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  final TextEditingController txtConfirmPassword = TextEditingController();
  final GlobalKey<FormState> _keyForm = GlobalKey<FormState>();

  Future<void> registerUser(
      String fullname, String username, String password) async {
    var uri = Uri.parse("${AppUrl.url}register_user.php");
    try {
      EasyLoading.show(status: 'Loading...');
      await Future.delayed(const Duration(seconds: 3));
      final response = await http.post(uri, body: {
        'FullName': fullname,
        'UserName': username,
        'Password': password,
      });

      if (!mounted) return; // Avoid context issues if widget is disposed.

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == 1) {
          EasyLoading.dismiss();
          EasyLoading.showSuccess('Success!');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginUser()),
          );
        } else {
          EasyLoading.showError(data['msg_error'] ?? 'Registration failed');
        }
      } else {
        EasyLoading.showError('Failed to connect to the server.');
      }
    } catch (e) {
      EasyLoading.showError('An unexpected error occurred.');
      debugPrint('Error: $e');
    } finally {
      if (EasyLoading.isShow) EasyLoading.dismiss();
    }
  }

  void togglePasswordVisibility() {
    setState(() => isPassword = !isPassword);
  }

  void toggleConfirmPasswordVisibility() {
    setState(() => isConfirmPassword = !isConfirmPassword);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              'Create Account',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.blueAccent,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          body: Form(
            key: _keyForm,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: [
                const SizedBox(height: 40),
                Center(
                  child:
                      Image.asset('assets/User3.png', width: 100, height: 100),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: txtUserName,
                  label: 'Username',
                  icon: Icons.person,
                  validator: (value) =>
                      value!.isEmpty ? 'Username required' : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: txtFullName,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (value) =>
                      value!.isEmpty ? 'Full Name required' : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: txtPassword,
                  label: 'Password',
                  icon: Icons.lock,
                  isObscure: isPassword,
                  toggleVisibility: togglePasswordVisibility,
                  validator: (value) =>
                      value!.isEmpty ? 'Password required' : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: txtConfirmPassword,
                  label: 'Confirm Password',
                  icon: Icons.lock_outline,
                  isObscure: isConfirmPassword,
                  toggleVisibility: toggleConfirmPasswordVisibility,
                  validator: (value) {
                    if (value!.isEmpty) return 'Confirmation required';
                    if (value != txtPassword.text)
                      return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      if (_keyForm.currentState!.validate()) {
                        registerUser(
                          txtFullName.text.trim(),
                          txtUserName.text.trim(),
                          txtPassword.text.trim(),
                        );
                      }
                    },
                    child: const Text(
                      'SIGN UP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginUser()),
                        );
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isObscure = false,
    void Function()? toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent, size: 28),
        suffixIcon: isObscure
            ? GestureDetector(
                onTap: toggleVisibility,
                child: Icon(
                  isObscure ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                  size: 28,
                ),
              )
            : null,
      ),
    );
  }
}
