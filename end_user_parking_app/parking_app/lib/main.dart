import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:parking_app/firebase_options.dart';
import 'package:parking_app/repositary/authentication_repositary.dart';
import 'package:parking_app/views/account_create_screen.dart';
import 'package:parking_app/views/home_page.dart';
import 'package:parking_app/views/loginscreen.dart';
import 'package:parking_app/views/parkingdetailsscreen.dart';
import 'package:parking_app/views/search_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((value) => Get.put(AuthenticationRepository()));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/account_creation': (context) =>
            const AccountCreationScreen(), // Use AccountCreationPage class
        '/home': (context) => HomePage(),
        '/search':(context) =>SearchPage(),
        // Add more routes as needed
      },
    );
  }
}
