import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for DateFormat
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parking_app/views/confirmation.dart';

class BookingScreen extends StatefulWidget {
  final int spaceId;
  final String spaceName;

  const BookingScreen(
      {Key? key, required this.spaceId, required this.spaceName})
      : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late TextEditingController _vehicleNumberController;
  String? _enteredVehicleNumber;
  late DateTime _selectedTime;
  String _enteredVehicleType = ''; // Add vehicle type variable
  bool _isTwoWheeler = false;

  @override
  void initState() {
    super.initState();
    _vehicleNumberController = TextEditingController();
    // Initialize the default time to the nearest half-hour interval from the current time
    final now = DateTime.now();
    int nextHour = now.hour;
    int nextMinute = now.minute < 30 ? 30 : 0;
    if (nextMinute == 0) {
      nextHour++;
    }
    _selectedTime =
        DateTime(now.year, now.month, now.day, nextHour, nextMinute);
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
        // Check if vehicle is two-wheeler
        _isTwoWheeler = vehicleNumber.length == 2;
      });
      _vehicleNumberController.clear(); // Clear the text field
    }
  }

  void _selectTime(BuildContext context) {
    final List<Widget> items = [];

    final now = DateTime.now();
    DateTime currentTime = now
        .subtract(Duration(minutes: now.minute % 30))
        .add(Duration(minutes: 30));

    DateTime threeHoursLater = now.add(Duration(hours: 3));

    // Generate time slots at 30-minute intervals from now to 3 hours later
    while (currentTime.isBefore(threeHoursLater)) {
      final formattedTime = DateFormat('h:mm a').format(currentTime);
      items.add(
        _buildTimeSlotWidget(formattedTime, currentTime),
      );
      currentTime = currentTime.add(Duration(minutes: 30));
    }

    // Show time selection
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.access_time),
                title: Text(
                  'Select Parking Time',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Column(
                children: items,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeSlotWidget(String formattedTime, DateTime currentTime) {
    return ListTile(
      leading: Icon(Icons.access_time),
      title: Text(
        formattedTime,
        style: TextStyle(fontSize: 18),
      ),
      onTap: () {
        _handleTimeSelection(currentTime);
      },
    );
  }

  void _handleTimeSelection(DateTime selectedTime) {
    setState(() {
      _selectedTime = selectedTime; // Update _selectedTime with the tapped time
    });
    Navigator.of(context).pop(selectedTime); // Pass tapped time back
  }

  void _selectVehicleType(BuildContext context) {
    final List<Widget> items = [];

    items.add(ListTile(
      leading: Icon(Icons.directions_car),
      title: Text(
        'Four Wheeler',
        style: TextStyle(fontSize: 18),
      ),
      onTap: () {
        setState(() {
          _isTwoWheeler = false;
          _enteredVehicleType =
              'Four Wheeler'; // Update the chosen vehicle type
        });
        Navigator.of(context).pop();
      },
    ));

    items.add(ListTile(
      leading: Icon(Icons.motorcycle),
      title: Text(
        'Two Wheeler',
        style: TextStyle(fontSize: 18),
      ),
      onTap: () {
        setState(() {
          _isTwoWheeler = true;
          _enteredVehicleType = 'Two Wheeler'; // Update the chosen vehicle type
        });
        Navigator.of(context).pop();
      },
    ));

    // Show vehicle type selection
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.directions_car),
                title: Text(
                  'Select Vehicle Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Column(
                children: items,
              ),
            ],
          ),
        );
      },
    );
  }

  void _bookParking() {
    _addVehicle();
    print(_enteredVehicleNumber);
    print(_selectedTime);
    print(_enteredVehicleType);
    if (_enteredVehicleNumber != null &&
        _enteredVehicleNumber!.isNotEmpty &&
        _selectedTime != null &&
        _enteredVehicleType.isNotEmpty) {
      // Check if vehicle type is selected
      // Proceed with booking
      _confirmBooking();
    } else {
      // Show error message if any field is empty
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(
              'Please enter a vehicle number, select a time, and choose a vehicle type.'),
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

  void _confirmBooking() {
    // Add the booking details to the Firestore collection
    FirebaseFirestore.instance.collection('BOOKING USERS').add({
      'entry_time': Timestamp.fromDate(DateTime.now()),
      'space_id': widget.spaceId,
      'vehicle_number': _enteredVehicleNumber,
      'vehicle_type': _enteredVehicleType, // Save selected vehicle type
      'booking_time': Timestamp.fromDate(_selectedTime),
    }).then((value) {
      // Success, navigate back or do something else
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsReservation(
            vehicleNumber: _enteredVehicleNumber.toString(),
            vehicleType: _enteredVehicleType,
            bookingTime: DateFormat('h:mm a').format(_selectedTime).toString(),
            parkingSpaceName: widget.spaceName,
          ),
        ),
      );
    }).catchError((error) {
      // Error handling
      print('Error booking parking: $error');
      // Show error message or retry
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_null_comparison
    String formattedTime = _selectedTime != null
        ? DateFormat('h:mm a').format(_selectedTime)
        : 'Select Time'; // Format the selected time for display

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
            // ElevatedButton(
            //   onPressed: _addVehicle,
            //   child: Text(
            //     'Add Vehicle',
            //     style: TextStyle(fontSize: 20),
            //   ),
            // ),
            SizedBox(height: 16),
            InkWell(
              onTap: () => _selectTime(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text(
                      'Parking Time:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      formattedTime,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: () => _selectVehicleType(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Icon(_isTwoWheeler
                        ? Icons.motorcycle
                        : Icons.directions_car),
                    title: Text(
                      'Vehicle Type:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _enteredVehicleType.isNotEmpty
                          ? _enteredVehicleType
                          : 'Select Vehicle Type', // Display selected vehicle type
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Warning: Delay of more than 30 minutes may lead to cancellation of reservation.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _bookParking,
              child: Text(
                'Book Now',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
