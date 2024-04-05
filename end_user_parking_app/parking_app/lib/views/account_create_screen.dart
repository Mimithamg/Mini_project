import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parking_app/controllers/signup_controller.dart';

class AccountCreationScreen extends StatefulWidget {
  const AccountCreationScreen({super.key});

  @override
  State<AccountCreationScreen> createState() => _AccountCreationScreenState();
}

class _AccountCreationScreenState extends State<AccountCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _firstNameError;
  String? _lastNameError;
  String? _mobileNumberError;
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignUpController());
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.1), // 10% of screen height
                  Text(
                    'Register to',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'PARK.IN',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Redex Pro',
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.05), // 5% of screen height
                  Text(
                    'Please create account to continue',
                    style: TextStyle(
                      fontFamily: 'Readex Pro',
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.04), // 4% of screen height
                  Container(
                    width:
                        double.infinity, // Make the container take full width
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFf4f6ff),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          width: double
                              .infinity, // Make the container take full width
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                if (value.isEmpty) {
                                  _firstNameError = 'First name is required';
                                } else if (value.contains(RegExp(r'[0-9]'))) {
                                  _firstNameError =
                                      'Name cannot contain digits';
                                } else {
                                  _firstNameError = null;
                                }
                              });
                            },
                            controller: controller.firstName,
                            decoration: InputDecoration(
                              hintText: 'First Name',
                              prefixIcon: Icon(Icons.person_2_outlined),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
// Display error message if there's an error
                        if (_firstNameError != null)
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              _firstNameError!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        SizedBox(height: 20.0),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFf4f6ff),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                if (value.isEmpty) {
                                  _lastNameError = 'Last name is required';
                                } else if (value.contains(RegExp(r'[0-9]'))) {
                                  _lastNameError = 'Name cannot contain digits';
                                } else {
                                  _lastNameError = null;
                                }
                              });
                            },
                            controller: controller.lastName,
                            decoration: InputDecoration(
                              hintText: 'Last Name',
                              prefixIcon: Icon(Icons.person_2_outlined),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_lastNameError != null)
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              _lastNameError!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFf4f6ff),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextFormField(
                            controller: controller.email,
                            decoration: InputDecoration(
                                hintText: 'Your email address',
                                prefixIcon: Icon(Icons.email_outlined),
                                border: InputBorder.none),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFf4f6ff),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                _mobileNumberError = isValidPhoneNumber(value)
                                    ? null
                                    : 'Please enter a valid mobile number';
                              });
                            },
                            controller: controller.phoneNo,
                            decoration: InputDecoration(
                              hintText: 'Mobile Number',
                              prefixIcon: Icon(Icons.phone_android_outlined),
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        if (_mobileNumberError != null)
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              _mobileNumberError!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFf4f6ff),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextFormField(
                            controller: controller.password,
                            decoration: InputDecoration(
                                hintText: 'Your password',
                                prefixIcon: Icon(Icons.lock_outline),
                                border: InputBorder.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.05), // 25% of screen height

                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.02), // 5% of screen height
                  Container(
                    width:
                        double.infinity, // Make the container take full width
                    child: SizedBox(
                      width:
                          double.infinity, // Make the SizedBox take full width
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                email: controller.email.text.trim(),
                                password: controller.password.text.trim(),
                              );
                              // Registration successful, navigate to verification page
                              Navigator.pushNamed(context, '/home');
                            } catch (e) {
                              // Registration failed, handle error
                              print('Error registering user: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Registration failed. Please try again.'),
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          'Create Account',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff567DF4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.05), // 5% of screen height
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Navigate to account creation page
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Already have an account ? login',
                        style: TextStyle(color: Color(0xff567DF4)),
                      ),
                      style: ButtonStyle(
                        alignment: Alignment
                            .center, // Align the button's child text to center
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.02), // 2% of screen height
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool isValidPhoneNumber(String value) {
    // Define your pattern for a valid phone number
    RegExp regex = RegExp(r'^[0-9]{10}$');
    return regex.hasMatch(value);
  }
}
