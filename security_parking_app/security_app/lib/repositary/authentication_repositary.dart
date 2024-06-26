import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:security_app/repositary/authentication_repositary/signup_email_password_failure.dart';
import 'package:security_app/screens/security_homescreen.dart';
import 'package:security_app/screens/loginscreen.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final Rx<User?> firebaseUser;

  @override
  void onInit() {
    super.onInit();
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    user == null
        ? Get.offAll(() => LoginScreen())
        : _navigateToHome(); // Navigate to home page after login
  }

  _navigateToHome() {
    // Add your home page navigation logic here
    // For example:
    Get.offAll(() => HomeScreen(isStaff:true,));
  }

  

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print("successfully logged in");
    } on FirebaseAuthException catch (e) {
      final ex = SignUpWithEmailAndPasswordFailure.code(e.code);
      print('FIREBASE AUTH EXCEPTION - ${ex.message}');
      throw ex;
    } catch (_) {
      const ex = SignUpWithEmailAndPasswordFailure();
      print('EXCEPTION - ${ex.message}');
      throw ex;
    }
  }
}
