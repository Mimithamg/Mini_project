import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:parking_app/firebase_options.dart';
import 'package:parking_app/repositary/authentication_repositary.dart';
import 'package:parking_app/views/login_page.dart'; // Import other pages as needed
import 'package:parking_app/views/account_creation_page.dart'; // Import AccountCreationPage
import 'package:parking_app/views/home_page.dart';

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
        '/login': (context) => LoginPage(),
        '/account_creation': (context) =>
            AccountCreationPage(), // Use AccountCreationPage class
        '/home': (context) => HomePage(),
        // Use OtpVerificationPage class
        // Add more routes as needed
      },
    );
  }
}
