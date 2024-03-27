import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatelessWidget {
  // GlobalKey for accessing form state
  late String _mobileNumber = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 50.0),
              Image.asset(
                'assets/car.png', // Replace 'assets/logo.png' with your logo path
                height: 150.0,
                width: 150.0,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20.0),
              Text(
                'Parking App',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  _mobileNumber = value;
                  // Store the mobile number value
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  print(_mobileNumber);

                  int count = _mobileNumber.length;
                  print(count);

                  if (count == 10) {
                    // Navigation
                    Navigator.pushNamed(context, '/otp_verification');
                  } else {
                    // Handle invalid mobile number
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Please enter a valid 10-digit mobile number')),
                    );
                  }
                },
                child: Text('Login'),
              ),
              SizedBox(height: 20.0),
              TextButton(
                onPressed: () {
                  // Navigate to account creation page
                  Navigator.pushNamed(context, '/account_creation');
                },
                child: Text('Don\'t have an account? Create one'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
