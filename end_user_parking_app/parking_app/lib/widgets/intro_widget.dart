import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget IntroWidget(BuildContext context) {
  final double screenHeight = MediaQuery.of(context).size.height;
  final double screenWidth = MediaQuery.of(context).size.width;
  return Column(
    children: [
      SizedBox(height: screenHeight * 0.1),
      Container(
        width: screenWidth,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/otp.png'), fit: BoxFit.cover),
        ),
        height: screenHeight * 0.4,
        alignment: FractionalOffset(0, -0.3),
      ),
    ],
  );
}
