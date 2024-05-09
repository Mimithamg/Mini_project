import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingScreen extends StatefulWidget {
  final int spaceId;

  const BookingScreen({Key? key, required this.spaceId}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late TextEditingController _vehicleNumberController;
  String? _enteredVehicleNumber;

  @override
  void initState() {
    super.initState();
    _vehicleNumberController = TextEditingController();
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    super.dispose();
  }

  void _addVehicle() {
    String vehicleNumber = _vehicleNumberController.text.trim();
    if (vehicleNumber.isNotEmpty) {
      setState(() {
        _enteredVehicleNumber = vehicleNumber;
      });
      _vehicleNumberController.clear(); // Clear the text field
    }
  }

  void _bookParking() {
    if (_enteredVehicleNumber != null && _enteredVehicleNumber!.isNotEmpty) {
      // Add the vehicle number to the Firestore collection
      FirebaseFirestore.instance.collection('BOOKING USERS').add({
        'entry_time': Timestamp.now(),
        'space_id': widget.spaceId,
        'vehicle_number': _enteredVehicleNumber,
      }).then((value) {
        // Success, navigate back or do something else
        Navigator.pop(context);
      }).catchError((error) {
        // Error handling
        print('Error booking parking: $error');
        // Show error message or retry
      });
    } else {
      // Show error message if vehicle number is empty
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please enter a vehicle number.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Parking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _vehicleNumberController,
              decoration: InputDecoration(
                labelText: 'Enter Vehicle Number',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addVehicle,
              child: Text('Add Vehicle',style: TextStyle( fontSize: 20),
              ),
            ),
            SizedBox(height: 16),
            if (_enteredVehicleNumber != null && _enteredVehicleNumber!.isNotEmpty)
              Text(
                _enteredVehicleNumber!,
                style: TextStyle( fontSize: 30,fontWeight: FontWeight.bold),
              ),
             // Added spacer to push the button to the bottom
            ElevatedButton(
              onPressed: _bookParking,
              child: Text('Book Now',
                style: TextStyle( fontSize: 18,fontWeight: FontWeight.bold),),
            ),
          ],
        ),
      ),
    );
  }
}
