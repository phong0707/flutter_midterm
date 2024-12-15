import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_application_1/app_url.dart';
import 'package:mobile_application_1/screen/app_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String? _username;
  String? _fullname;
  String? _phone;
  String? _email;
  String _image = 'default.png';
  File? _newImage;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  TextEditingController _fullnameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _username = sp.getString("USER_NAME");
      _fullname = sp.getString("USER_FULLNAME");
      _phone = sp.getString("USER_PHONE");
      _email = sp.getString("USER_EMAIL");
      _image = sp.getString("USER_IMAGE") ?? 'default.png'; // Updated image

      // Set initial values for the form controllers
      _usernameController.text = _username ?? '';
      _fullnameController.text = _fullname ?? '';
      _phoneController.text = _phone ?? '';
      _emailController.text = _email ?? '';
    });
  }

  Future<void> _pickImage() async {
    final sp = await SharedPreferences.getInstance();
    String userId = sp.getString("USER_ID")!; // Ensure USER_ID exists

    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    var url = Uri.parse("${AppUrl.url}change_image_profile.php");

    if (file != null) {
      final request = http.MultipartRequest("POST", url)
        ..fields['user_id'] = userId; // Pass user_id in request body
      request.files.add(await http.MultipartFile.fromPath("image", file.path));

      try {
        final res = await request.send();

        if (res.statusCode == 200) {
          final data = await res.stream.bytesToString();
          final msg = json.decode(data);
          if (msg['success'] == 1) {
            await sp.setString("USER_IMAGE", "${msg['image_update']}");
            await _loadUserData(); // Reload user data to update image
            EasyLoading.showSuccess(msg['msg_success']);
          } else {
            EasyLoading.showError(msg['msg_error']);
          }
        } else {
          EasyLoading.showError("Failed to upload image: ${res.statusCode}");
        }
      } catch (e) {
        EasyLoading.showError("Error: $e");
      }
    } else {
      EasyLoading.showError("No image selected.");
    }
  }

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

      if (response.statusCode == 200) {
        try {
          final msg = json.decode(response.body);

          if (msg['success'] == 1) {
            await sp.setString("USER_NAME", _usernameController.text);
            await sp.setString("USER_FULLNAME", _fullnameController.text);
            await sp.setString("USER_PHONE", _phoneController.text);
            await sp.setString("USER_EMAIL", _emailController.text);
            EasyLoading.showSuccess(msg['msg_success']);
            Navigator.of(context).pop(); // Close the dialog
            setState(() {
              _loadUserData(); // Reload user data to reflect updates
            });
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
        title: const Text('User Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AppDashboard()),
            ); // Navigate back to the previous screen
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            topPortion(_image),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      _fullname ?? 'Full Name',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text('Account Details',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  detailRow('Username:', '@${_username ?? "Username"}'),
                  detailRow('Full Name:', _fullname ?? "Full Name"),
                  detailRow('Phone Number:', _phone ?? "Phone Number"),
                  detailRow('Email:', _email ?? "Email"),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Show Edit Profile Dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Edit Profile'),
                              content: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      controller: _usernameController,
                                      decoration: const InputDecoration(
                                          labelText: 'Username'),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your username';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _fullnameController,
                                      decoration: const InputDecoration(
                                          labelText: 'Full Name'),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your full name';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _phoneController,
                                      decoration: const InputDecoration(
                                          labelText: 'Phone Number'),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your phone number';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _emailController,
                                      decoration: const InputDecoration(
                                          labelText: 'Email'),
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            !value.contains('@')) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: _saveProfile,
                                  child: const Text('Save Changes'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        child: Text('Edit Profile',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget topPortion(String image) {
    return Stack(
      children: [
        Container(
          height: 200,
          decoration: const BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 140,
              height: 170,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: _newImage != null
                          ? Image.file(
                              _newImage!,
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              '${AppUrl.url}images/$image',
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/default_profile.png',
                                  width: 140,
                                  height: 140,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 5,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blueGrey,
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
