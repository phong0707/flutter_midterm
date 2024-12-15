import 'package:flutter/material.dart';
import 'package:mobile_application_1/Menu/about_us.dart';
import 'package:mobile_application_1/Menu/change_password.dart';
import 'package:mobile_application_1/Menu/contact_us.dart';
import 'package:mobile_application_1/Menu/faqs.dart';
import 'package:mobile_application_1/Menu/feedback.dart';
import 'package:mobile_application_1/Menu/my_profile.dart';
import 'package:mobile_application_1/Menu/promotions.dart';
import 'package:mobile_application_1/Menu/terms_of_use.dart';
import 'package:mobile_application_1/app_url.dart';
import 'package:mobile_application_1/screen/app_colors.dart';
import 'package:mobile_application_1/screen/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  String? _userName;
  String? _email;
  String _image = "default.png";

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // Load user information on initialization
  }

  Future<void> _loadUserInfo() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _userName = sp.getString("USER_NAME") ?? 'Guest';
      _email =
          sp.getString("USER_EMAIL") ?? 'Guest'; // Default to 'Guest' if null
      _image = sp.getString("USER_IMAGE") ??
          'default.png'; // Use a fallback image if null
    });
  }

  Future<void> _logoutUser() async {
    final sp = await SharedPreferences.getInstance();
    await sp.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginUser()));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_userName ??
                'Loading...'), // Show 'Loading...' while fetching user info
            accountEmail: Text(_email ?? 'Loading...'),
            currentAccountPicture: ClipOval(
              child: SizedBox(
                width: 90, // Set the desired width
                height: 90, // Set the desired height
                child: _image.isNotEmpty
                    ? Image.network(
                        '${AppUrl.url}images/$_image',
                        fit: BoxFit.cover, // Ensures the image fills the oval
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons
                                .person, // Fallback icon in case of an image load error
                            size: 60,
                            color: Colors.grey,
                          );
                        },
                      )
                    : const Icon(
                        Icons.person, // Fallback icon if image path is empty
                        size: 60,
                        color: Colors.grey,
                      ),
              ),
            ),

            decoration: const BoxDecoration(color: AppColors.blue),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('About Us'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutUs(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone_in_talk),
            title: const Text('Contact Us'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContactUs(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('Promotions'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Promotions(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.question_mark),
            title: const Text('FAQS'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Faqs(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feedback'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const feedbacks(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.thermostat_sharp),
            title: const Text('Terms of Use'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsOfUse(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserProfile(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text('Change Password'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePassword(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              _logoutUser();
            },
          ),
        ],
      ),
    );
  }
}
