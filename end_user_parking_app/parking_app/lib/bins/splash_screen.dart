import 'dart:async';
import 'package:flutter/material.dart';
import 'package:parking_app/lib/utils/app_export.dart';
import 'package:parking_app/lib/utils/image_constant.dart';
import 'package:parking_app/theme/theme_helper.dart';
import 'package:parking_app/views/loginscreen.dart';
import 'package:parking_app/widgets/custom_image_view.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Using a Future.delayed to wait for 2 seconds before navigating to the login page
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate to your login page
      );
    });

    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomImageView(
                imagePath: ImageConstant.ingBackground,
                height: 224.v,
                width: 103.h,
                alignment: Alignment.centerRight,
              ),
              Spacer(flex: 59),
              Padding(
                padding: EdgeInsets.only(left: 128.h),
                child: Text(
                  "Park.in",
                  style: theme.textTheme.headlineLarge,
                ),
              ),
              Spacer(flex: 40),
              CustomImageView(
                imagePath: ImageConstant.ingBackground1,
                height: 309.v,
                width: 328.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
