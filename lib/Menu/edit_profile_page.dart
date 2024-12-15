import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_application_1/Menu/my_profile.dart';
import 'package:mobile_application_1/app_url.dart';
import 'package:mobile_application_1/screen/app_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  String? _username;
  String? _fullname;
  String? _phone;
  String? _email;

  final TextEditingController _usernameController = TextEditingController();
  TextEditingController _fullnameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load the user data from SharedPreferences and populate the form fields
  Future<void> _loadUserData() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _username = sp.getString("USER_NAME");
      _fullname = sp.getString("USER_FULLNAME");
      _phone = sp.getString("USER_PHONE");
      _email = sp.getString("USER_EMAIL");

      _usernameController.text = _username ?? '';
      _fullnameController.text = _fullname ?? '';
      _phoneController.text = _phone ?? '';
      _emailController.text = _email ?? '';
    });
  }

  // Save the updated profile data
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final sp = await SharedPreferences.getInstance();
      String? strId = sp.getString("USER_ID");

      if (strId == null) {
        EasyLoading.showError("User ID not found.");
        return;
      }

      var url = Uri.parse("${AppUrl.url}update_profile.php");
      final response = await http.post(url, body: {
        'user_id': strId,
        'username': _usernameController.text,
        'fullname': _fullnameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
      });

      // Debugging the response
      // print("Response status: ${response.statusCode}");
      // print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final msg = json.decode(response.body);

          if (msg['success'] == 1) {
            // Save the updated values in SharedPreferences
            await sp.setString("USER_NAME", _usernameController.text);
            await sp.setString("USER_FULLNAME", _fullnameController.text);
            await sp.setString("USER_PHONE", _phoneController.text);
            await sp.setString("USER_EMAIL", _emailController.text);

            // If the server returns user-specific information like image or type, you can update those too
            await sp.setString("USER_ID", "${msg['userID']}");
            await sp.setString("USER_PWD", "${msg['userPwd']}");
            await sp.setString("USER_TYPE", "${msg['userType']}");
            await sp.setBool("ISLOGGEDIN",
                true); // Optional, depending on your app's login state

            EasyLoading.showSuccess(msg['msg_success']);
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserProfile()),
            );
          } else {
            EasyLoading.showError(msg['msg_error']);
          }
        } catch (e) {
          EasyLoading.showError("Error decoding response: $e");
        }
      } else {
        EasyLoading.showError("Failed to load data: ${response.statusCode}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Username field
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Full name field
              TextFormField(
                controller: _fullnameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone number field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Save button
              Center(
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
