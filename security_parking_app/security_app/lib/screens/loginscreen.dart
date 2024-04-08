import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:security_app/repositary/authentication_repositary.dart';
import 'package:security_app/lib/repositary/authentication_repositary.dart';
import 'package:security_app/screens/security_homescreen.dart'; // Import your HomeScreen here

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Text(
                  'Welcome to',
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.10),
                Text(
                  'Please login to your account to continue',
                  style: TextStyle(
                    fontFamily: 'Readex Pro',
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                Container(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFf4f6ff),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                              hintText: 'Your email address',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: InputBorder.none),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFf4f6ff),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextFormField(
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                              hintText: 'Your password',
                              prefixIcon: Icon(Icons.lock_outline),
                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                                child: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                              border: InputBorder.none),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Reset Password'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          decoration: InputDecoration(
                                              labelText: 'Email'),
                                        ),
                                      ],
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // Reset password logic
                                        },
                                        child: Text('Reset'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text(
                              'Forgot password ?',
                              style: TextStyle(color: Color(0xff567DF4)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Container(
                  width: double.infinity,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: ()  {
                        final String email = _emailController.text.trim();
                        final String password = _passwordController.text.trim();

                        if (email.isNotEmpty && password.isNotEmpty) {
                          login(email, password, context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please enter email and password'),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'LOGIN',
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void login(String email, String password, BuildContext context) async {
    
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Login successful, navigate to home page
      Navigator.pushNamed(context, '/home');
    } catch (e) {
      // Login failed, handle error
      print('Error logging in user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed. Please try again.'),
        ),
      );
    }
  }
}