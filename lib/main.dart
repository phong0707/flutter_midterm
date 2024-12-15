import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mobile_application_1/screen/app_colors.dart';
import 'package:mobile_application_1/screen/app_dashboard.dart';
import 'package:mobile_application_1/screen/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // creating an instance/object of class
  // className objectName = constructorName([parameter_list]);
  // var/const objectName = constructorName([parameter_list]);
  // const app = HomeApp();
  WidgetsFlutterBinding.ensureInitialized();
  final sp = await SharedPreferences.getInstance();
  final checkloggedIn = sp.getBool("ISLOGGEDIN") ?? false;
  runApp(HomeApp(IsLoggedIn: checkloggedIn));
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = true;
  //..customAnimation = CustomAnimation();
}

class HomeApp extends StatelessWidget {
  final bool IsLoggedIn;
  const HomeApp({super.key, required this.IsLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login User',
      // varname = (condition) ? result_if_true : result_if_false:
      home: IsLoggedIn ? const AppDashboard() : const LoginUser(),
      theme: ThemeData.light().copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.blue,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
      ),
      builder: EasyLoading.init(),
    );
  }
}
