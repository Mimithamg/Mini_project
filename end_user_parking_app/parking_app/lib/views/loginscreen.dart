import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _passwordVisible = false;
  bool _checkboxValue = false;

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
                          controller: emailController,
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
                          controller: passwordController,
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
                              //forgot password screen
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
                Row(
                  children: [
                    Checkbox(
                      value: _checkboxValue,
                      onChanged: (newValue) {
                        setState(() {
                          _checkboxValue = newValue!;
                        });
                      },
                    ),
                    Text(
                      'I agree the',
                    ),
                    TextButton(
                      onPressed: () {
                        //forgot password screen
                      },
                      child: Text(
                        'Terms and conditions',
                        style: TextStyle(color: Color(0xff567DF4)),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.02), // 5% of screen height
                Container(
                  width: double.infinity, // Make the container take full width
                  child: SizedBox(
                    width: double.infinity, // Make the SizedBox take full width
                    child: ElevatedButton(
                      onPressed: () {
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();

                        if (email.isNotEmpty && password.isNotEmpty) {
                          login(email, password, context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please enter email and password'),
                            ),
                          );
                        }

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
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Navigate to account creation page
                      Navigator.pushNamed(context, '/account_creation');
                    },
                    child: Text(
                      'Don\'t have an account? Create one',
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
    );
  }

  void login(String email, String password, BuildContext context) async {
    if (!_checkboxValue) {
      // Show an alert dialog informing the user to agree to terms and conditions
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Terms and Conditions"),
            content: Text(
                "Please read and agree to the terms and conditions before logging in."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return; // Return without proceeding with login
    }
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Login successful, navigate to home page
      Navigator.pushNamed(context, '/home');
      _showLocationPermissionDialog(context);
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

  void _showLocationPermissionDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Permission'),
          content: Text('Do you want to turn on location services?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                LocationPermission permission =
                    await Geolocator.requestPermission();
                if (permission == LocationPermission.always ||
                    permission == LocationPermission.whileInUse) {
                  bool serviceEnabled =
                      await Geolocator.isLocationServiceEnabled();
                  if (!serviceEnabled) {
                    bool serviceTurnedOn =
                        await Geolocator.openLocationSettings();
                    if (serviceTurnedOn) {
                      _getCurrentLocation(context);
                    } else {
                      print('Location service was not turned on.');
                    }
                  } else {
                    _getCurrentLocation(context);
                  }
                } else {
                  print('Location permission was not granted.');
                }
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _getCurrentLocation(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled, prompt the user to enable them.
      _showLocationServiceDisabledDialog(context);
    } else {
      // Location services are enabled, attempt to get the current location.
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        print('Current Location: ${position.latitude}, ${position.longitude}');
      } catch (e) {
        print('Error getting current location: $e');
      }
    }
  }

  void _showLocationServiceDisabledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Service Disabled'),
          content: Text('Please enable location services to continue.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Optionally navigate to location settings
                //_navigateToLocationSettings();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
