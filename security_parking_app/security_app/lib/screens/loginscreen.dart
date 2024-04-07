import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passwordVisible = false;
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
                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.1), // 10% of screen height
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
                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.10), // 5% of screen height
                Text(
                  'Please login to your account to continue',
                  style: TextStyle(
                    fontFamily: 'Readex Pro',
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.04), // 4% of screen height
                Container(
                  width: double.infinity, // Make the container take full width
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFf4f6ff),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextFormField(
                          //controller: emailController,
                          decoration: InputDecoration(
                              hintText: 'Your email address',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: InputBorder.none),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.03), // 3% of screen height
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFf4f6ff),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextFormField(
                          //controller: passwordController,
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
                                          //controller: emailController,
                                          decoration: InputDecoration(
                                              labelText: 'Email'),
                                        ),
                                      ],
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          //resetPassword(context);
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
                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.05), // 25% of screen height

                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.02), // 5% of screen height
                Container(
                  width: double.infinity, // Make the container take full width
                  child: SizedBox(
                    width: double.infinity, // Make the SizedBox take full width
                    child: ElevatedButton(
                      onPressed: () {
                        //final email = emailController.text.trim();
                        //final password = passwordController.text.trim();

                        // if (email.isNotEmpty && password.isNotEmpty) {
                        //   login(email, password, context);
                        // } else {
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(
                        //       content: Text('Please enter email and password'),
                        //     ),
                        //   );
                        // }

                        // Handle login button press
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
                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.05), // 5% of screen height
              ],
            ),
          ),
        ),
      ),
    );
  }
}
