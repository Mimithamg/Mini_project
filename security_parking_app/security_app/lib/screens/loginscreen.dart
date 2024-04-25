import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:security_app/screens/parking_space_details.dart'; // Import your ParkingSpaceDetailsScreen here

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
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03),
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
                      onPressed: () {
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
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        print('User Email: ${user.email}'); // Printing user email
        // Query Firestore collection 'users' using the user's email
        QuerySnapshot<
            Map<String,
                dynamic>> querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email',
                isEqualTo: user
                    .email) // Assuming 'email' is the field storing the email in your 'users' collection
            .get();

        if (querySnapshot.size > 0) {
          // If documents are found for the user's email
          DocumentSnapshot<Map<String, dynamic>> userDoc =
              querySnapshot.docs.first;
          Map<String, dynamic> userData = userDoc.data()!;

          // Retrieving assignedParkingSpaceId from userData
          dynamic assignedParkingSpaceId = userData['assignedParkingSpaceId'];

          if (assignedParkingSpaceId != null) {
            // Assigned parking space ID is not null
            print('Assigned Parking Space ID: $assignedParkingSpaceId');

            // Query Firestore collection 'PARKING SPACES' to check if assignedParkingSpaceId exists
            QuerySnapshot<Map<String, dynamic>> parkingSpaceSnapshot =
                await FirebaseFirestore.instance
                    .collection('PARKING SPACES')
                    .where('space_id', isEqualTo: assignedParkingSpaceId)
                    .get();

            if (parkingSpaceSnapshot.size > 0) {
              // If documents are found for the assigned parking space ID
              print('Assigned parking space ID is valid.');
              // Further processing...
              // Navigate to ParkingSpaceDetailsScreen and pass the parking space ID
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParkingSpaceDetailsScreen(
                      spaceId: assignedParkingSpaceId.toString()),
                ),
              );
            } else {
              // No documents found for the assigned parking space ID
              print('Assigned parking space ID is invalid.');
            }
          } else {
            // No assigned parking space ID found
            print('No assigned parking space ID for this user.');
          }
        } else {
          // No documents found for the user's email
          print('User document not found in Firestore');
        }
      }
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
