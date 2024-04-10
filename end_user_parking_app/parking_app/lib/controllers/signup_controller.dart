import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:parking_app/repositary/authentication_repositary.dart';

class SignUpController extends GetxController {
  static SignUpController get instance => Get.find();

  final email = TextEditingController();
  final password = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final phoneNo = TextEditingController();

  void registerUser(String email, String password) {
    AuthenticationRepository.instance.createUserWithEmailAndPassword(email, password);
  }
}
