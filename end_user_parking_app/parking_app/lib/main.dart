import 'package:flutter/material.dart';
import 'package:parking_app/views/login_page.dart'; // Import other pages as needed
import 'package:parking_app/views/account_creation_page.dart'; // Import AccountCreationPage
import 'package:parking_app/views/otp_verification_page.dart'; // Import OtpVerificationPage

void main() {
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
        '/account_creation': (context) => AccountCreationPage(), // Use AccountCreationPage class
        '/otp_verification': (context) => OtpVerificationPage(), // Use OtpVerificationPage class
        // Add more routes as needed
      },
    );
  }
}
