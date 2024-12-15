import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_application_1/Menu/encrypt_password.dart';
import 'package:mobile_application_1/app_url.dart';
import 'package:mobile_application_1/screen/app_colors.dart';
import 'package:mobile_application_1/screen/app_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool isPassword = true;
  bool isConfirmPassword = true;

  final TextEditingController txtPassword = TextEditingController();
  final TextEditingController txtConfirmPassword = TextEditingController();
  final GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
  static const String newPasswordSameAsOld =
      "Your new password is the same as the old password! Please enter a new password.";
  static const String serverError = "Failed to send data to server!";

  Future<void> _changePassword() async {
    final sp = await SharedPreferences.getInstance();
    final strId = sp.getString("USER_ID") ?? "";
    final strOldPwd = sp.getString("USER_PWD") ?? "";
    final strNewPwd = txtPassword.text.trim();
    final strMd5 = EncryptPassword.toMD5(strNewPwd);

    if (strMd5 == strOldPwd) {
      EasyLoading.showInfo(newPasswordSameAsOld);
      return;
    }

    final url = Uri.parse("${AppUrl.url}change_password.php");
    EasyLoading.show(status: "Updating...");
    try {
      await Future.delayed(const Duration(seconds: 1));
      final res = await http.post(url, body: {
        'userPassword': strMd5,
        'UserID': strId,
      });

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == 1) {
          sp.setString(
              "USER_PWD", strMd5); // Update password in SharedPreferences
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AppDashboard()),
          );
          EasyLoading.dismiss();
        } else {
          EasyLoading.showError(data['msg_error'] ?? "Unknown error occurred");
        }
      } else {
        EasyLoading.showError(serverError);
      }
    } catch (e) {
      EasyLoading.showError("An error occurred: $e");
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
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              'Change your password',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: AppColors.blue,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          body: Form(
            key: _keyForm,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/i.jpg',
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: txtPassword,
                  label: 'New Password',
                  icon: Icons.lock,
                  isObscure: isPassword,
                  toggleVisibility: togglePasswordVisibility,
                  validator: (value) =>
                      value!.isEmpty ? 'Password required' : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: txtConfirmPassword,
                  label: 'Confirm New Password',
                  icon: Icons.lock_outline,
                  isObscure: isConfirmPassword,
                  toggleVisibility: toggleConfirmPasswordVisibility,
                  validator: (value) {
                    if (value!.isEmpty) return 'Confirmation required';
                    if (value != txtPassword.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          if (_keyForm.currentState!.validate()) {
                            _changePassword();
                          }
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
