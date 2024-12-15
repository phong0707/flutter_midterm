// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_application_1/app_url.dart';
import 'package:mobile_application_1/screen/app_dashboard.dart';
import 'package:mobile_application_1/screen/signup.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginUser extends StatefulWidget {
  const LoginUser({super.key});

  @override
  State<LoginUser> createState() => _LoginUserState();
}

class _LoginUserState extends State<LoginUser> {
  bool ispassword = true;
  final txt = FocusNode();
  final _keyForm = GlobalKey<FormState>();

  final TextEditingController controllerUsername = TextEditingController();
  final TextEditingController controllerPassword = TextEditingController();

  Future<void> _loginUser(String userName, String Password) async {
    var uri = Uri.parse("${AppUrl.url}login_user.php");
    EasyLoading.show(status: 'Loading...');
    await Future.delayed(const Duration(seconds: 3));
    final response = await http.post(uri, body: {
      'UserLoginName': userName,
      'PasswordLogin': Password,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == 1) {
        // save user login info
        // sharedPreferences
        final sp = await SharedPreferences.getInstance();
        sp.setString("USER_ID", ("${data['userID']}"));
        sp.setString("USER_NAME", ("${data['userName']}"));
        sp.setString("USER_PWD", ("${data['	userPwd']}"));
        sp.setString("USER_TYPE", ("${data['userType']}"));
        sp.setString("USER_IMAGE", ("${data['userimg']}"));
        sp.setString("USER_EMAIL", ("${data['userEmail']}"));
        sp.setString("USER_FULLNAME", ("${data['fullName']}"));
        sp.setString("USER_PHONE", ("${data['phoneNumber']}"));
        sp.setBool("ISLOGGEDIN", true);

        EasyLoading.dismiss();
        EasyLoading.showSuccess('Success!');
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AppDashboard(),
          ),
        );
      } else {
        EasyLoading.showError("${data['msg_error']}");
      }
    } else {
      EasyLoading.showError('Failed to connect to the server.');
    }
  }

  void togglePassword() {
    setState(() {
      ispassword = !ispassword;
      if (txt.hasPrimaryFocus) return;
      txt.canRequestFocus = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Welcome to login',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.blueAccent,
          ),
        ),
        body: Form(
          key: _keyForm,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    // border: Border.all(color: Colors.blueAccent, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/i.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controllerUsername,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  labelText: 'Username',
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Colors.blueAccent,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: controllerPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                obscureText: ispassword,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  labelText: 'Password',
                  prefixIcon: const Icon(
                    Icons.lock,
                    color: Colors.blueAccent,
                    size: 28,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: togglePassword,
                    child: Icon(
                      ispassword
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: Colors.grey,
                      size: 28,
                    ),
                  ),
                ),
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
                      String strName =
                          controllerUsername.text.toString().trim();
                      String strPwd = controllerPassword.text.toString().trim();
                      _loginUser(strName, strPwd);
                    }
                  },
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Signup(),
                          ));
                    },
                    child: const Text(
                      'Sign Up',
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
    );
  }
}
