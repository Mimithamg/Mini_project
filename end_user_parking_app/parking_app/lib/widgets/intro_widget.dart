import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget IntroWidget() {
  return Column(
    children: [
      SizedBox(height: Get.height * 0.2),
      Container(
        width: Get.width,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/otp.png'), fit: BoxFit.cover),
        ),
        height: Get.height * .4,
        alignment: FractionalOffset(0, -0.3),
      ),
    ],
  );
}
