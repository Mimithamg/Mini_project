import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parking_app/views/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GetMaterialApp(
      theme: ThemeData(fontFamily: 'Roboto'), // ThemeData

      home: const LoginScreen(),
    ); // GetMaterialApp
  }
}
