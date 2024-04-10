import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parking_app/controllers/signup_controller.dart';

class AccountCreationPage extends StatefulWidget {
  @override
  _AccountCreationPageState createState() => _AccountCreationPageState();
}

class _AccountCreationPageState extends State<AccountCreationPage> {
  final _formKey = GlobalKey<FormState>();
  String? _firstNameError;
  String? _lastNameError;
  String? _mobileNumberError;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignUpController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        _firstNameError = 'First name is required';
                      } else if (value.contains(RegExp(r'[0-9]'))) {
                        _firstNameError = 'Name cannot contain digits';
                      } else {
                        _firstNameError = null;
                      }
                    });
                  },
                  controller: controller.firstName,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                    errorText: _firstNameError,
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
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
                    labelText: 'Last Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                    errorText: _lastNameError,
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: controller.email,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _mobileNumberError = isValidPhoneNumber(value)
                          ? null
                          : 'Please enter a valid mobile number';
                    });
                  },
                  controller: controller.phoneNo,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                    errorText: _mobileNumberError,
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: controller.password,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
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
                            content:
                                Text('Registration failed. Please try again.'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Create Account'),
                ),
                SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    // Navigate back to login page
                    Navigator.pop(context);
                  },
                  child: Text('Already created an account? Log in'),
                ),
              ],
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
