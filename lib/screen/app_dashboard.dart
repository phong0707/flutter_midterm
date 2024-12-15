import 'package:flutter/material.dart';
import 'package:mobile_application_1/Menu/navigation_menu.dart';
import 'package:mobile_application_1/app_url.dart';
import 'package:mobile_application_1/screen/MenuCard/category.dart';
import 'package:mobile_application_1/screen/MenuCard/contacts.dart';
import 'package:mobile_application_1/screen/MenuCard/groups.dart';
import 'package:mobile_application_1/screen/MenuCard/help.dart';
import 'package:mobile_application_1/screen/MenuCard/products.dart';
import 'package:mobile_application_1/screen/MenuCard/settings.dart';
import 'package:mobile_application_1/screen/app_colors.dart';
import 'package:mobile_application_1/screen/favorite_item.dart';
import 'package:mobile_application_1/screen/my_order.dart';
import 'package:mobile_application_1/screen/new_order.dart';
import 'package:mobile_application_1/screen/new_top.dart';
import 'package:mobile_application_1/screen/popular_items.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDashboard extends StatefulWidget {
  const AppDashboard({super.key});

  @override
  State<AppDashboard> createState() => _AppDashboardState();
}

class _AppDashboardState extends State<AppDashboard> {
  String? _fullname;
  String _image = "${AppUrl.url}images/default.png";

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // calling the method
  }

  Future<void> _loadUserInfo() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _fullname = sp.getString("USER_FULLNAME") ?? 'Guest';
      _image = sp.getString("USER_IMAGE") ?? 'default.png';
    });
  }

  Future<void> _updateUserInfo(String fullname, String image) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString("USER_FULLNAME", fullname);
    await sp.setString("USER_IMAGE", image);
    setState(() {
      _fullname = fullname;
      _image = image;
    });
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        elevation: 0,
        title: const Center(
          child: Text(
            'BBU Store',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.add_shopping_cart, color: Colors.black87),
                  title: Text('New Order'),
                ),
              ),
              const PopupMenuItem(
                value: 2,
                child: ListTile(
                  leading: Icon(Icons.share, color: Colors.black87),
                  title: Text('Popular Items'),
                ),
              ),
              const PopupMenuItem(
                value: 3,
                child: ListTile(
                  leading: Icon(Icons.favorite, color: Colors.red),
                  title: Text('Favorite Items'),
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 1:
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NewOrder()));
                  break;
                case 2:
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PopularItems()));
                  break;
                case 3:
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FavoriteItem()));
                  break;
              }
            },
          ),
        ],
      ),
      drawer: const NavigationMenu(),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildGreetingCard(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildDashboardCard('Contacts', Icons.person, Colors.red,
                        () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Contacts()));
                    }),
                    _buildDashboardCard('Groups', Icons.people, Colors.orange,
                        () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Groups()));
                    }),
                    _buildDashboardCard(
                        'Products', Icons.shopping_cart, Colors.green, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Products()));
                    }),
                    _buildDashboardCard(
                        'Categories', Icons.playlist_add_check, Colors.blue,
                        () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Categories()));
                    }),
                    _buildDashboardCard('Help', Icons.help, Colors.purple, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Help()));
                    }),
                    _buildDashboardCard('Settings', Icons.settings, Colors.teal,
                        () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Settings()));
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreetingMessage(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_fullname',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MyOrder()));
                        },
                        child: const Text('My Orders',
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          side: const BorderSide(color: AppColors.blue),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const NewTop()));
                        },
                        child: const Text('New TOP',
                            style: TextStyle(color: AppColors.blue)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ClipOval(
              child: SizedBox(
                width: 90, // Set the desired width
                height: 90, // Set the desired height
                child: Image.network(
                  '${AppUrl.url}images/$_image',
                  fit: BoxFit.cover, // Ensures the image fills the oval
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person, // Fallback icon
                      size: 60,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
