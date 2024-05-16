import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for DateFormat
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parking_app/views/confirmation.dart';

class BookingScreen extends StatefulWidget {
  final int spaceId;
  final String spaceName;

  const BookingScreen({super.key, required this.spaceId, required this.spaceName});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late TextEditingController _vehicleNumberController;
  String? _enteredVehicleNumber;
  late DateTime _selectedTime;
  String _enteredVehicleType = ''; // Add vehicle type variable
  int? _selectedIndex;
  bool? _isFourWheeler;
  double? _feePerHourFourWheelers;
  double? _feePerHourTwoWheelers;
  

  @override
  void initState() {
    super.initState();
    _vehicleNumberController = TextEditingController();
    _fetchParkingFees();
    // Initialize the default time to the nearest half-hour interval from the current time
    final now = DateTime.now();
    int nextHour = now.hour;
    int nextMinute = now.minute < 30 ? 30 : 0;
    if (nextMinute == 0) {
      nextHour++;
    }
    _selectedTime = DateTime(now.year, now.month, now.day, nextHour, nextMinute);
    // Set initial values for vehicle type and fees
    _enteredVehicleType = '';
     // Fetch parking fees
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
      });
      _vehicleNumberController.clear(); // Clear the text field
    }
  }

 void _fetchParkingFees() async {
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('PARKING SPACES')
        .where('space_id', isEqualTo: widget.spaceId) // Query based on space_id
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _feePerHourFourWheelers = snapshot.docs[0]['fee_ph_four']?.toDouble() ?? 0.0;
        _feePerHourTwoWheelers = snapshot.docs[0]['fee_ph_two']?.toDouble() ?? 0.0;
        // Set feesLoaded to true after fetching fees
      });
    } else {
      // Handle case where document doesn't exist
      print('Document does not exist');
    }
  } catch (e) {
    // Handle errors more gracefully
    print('Error fetching parking fees: $e');
    // Show error message to the user
    // showDialog(...);
  }
}




  Widget _buildTimeSlotWidget(String formattedTime, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = isSelected ? null : index;
          _handleTimeSelection(index);
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        padding: EdgeInsets.all(13.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
          color: isSelected ? Color.fromARGB(255, 6, 87, 153) : Colors.white,
        ),
        child: Text(
          formattedTime,
          style: TextStyle(fontSize: 18, color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  void _handleTimeSelection(int index) {
    final now = DateTime.now();
    DateTime currentTime = now.subtract(Duration(minutes: now.minute % 30)).add(Duration(minutes: 30));
    _selectedTime = currentTime.add(Duration(minutes: 30 * index));
  }

 void _bookParking() {
  _addVehicle();
  print(_enteredVehicleNumber);
  print(_selectedTime);
  print(_enteredVehicleType);
  
  // Check if vehicle number and vehicle type are selected
  if (_enteredVehicleNumber != null &&
      _enteredVehicleNumber!.isNotEmpty &&
      _enteredVehicleType.isNotEmpty&&
      _selectedIndex != null) {
    // Proceed with booking
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Booking'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delay of more than 30 minutes may lead to cancellation of reservation.',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _confirmBooking(); // Proceed with booking
              },
              child: Text('Book Now'),
            ),
          ],
        );
      },
    );
  } else {
    // Show error message if any field is empty
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: const Text(
          'Please enter a VEHICLE NUMBER, choose a VEHICLE TYPE, and select ENTRY TIME.',
        ),
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
            spaceId: widget.spaceId,
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
    String formattedTime = _selectedTime != null ? DateFormat('h:mm a').format(_selectedTime) : 'Select Time'; // Format the selected time for display

    return Scaffold(
      appBar: AppBar(
        title: Text('Book Parking'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 5),
              const Text(
                'Vehicle Number:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _vehicleNumberController,
                decoration: const InputDecoration(
                  labelText: "Enter Vehicle number",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Vehicle Type:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2),
              Text('Select Vehicle Type'),
              Row(
                children: [
                  Checkbox(
                    value: _isFourWheeler == true,
                    onChanged: (value) {
                      setState(() {
                        if (_isFourWheeler == true) {
                          _isFourWheeler = null; // Deselect if already selected
                          _enteredVehicleType = '';
                        } else {
                          _isFourWheeler = true; // Select if not already selected
                          _enteredVehicleType = 'Four Wheeler';
                        }
                      });
                    },
                  ),
                  const Text('Four Wheeler', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 140),
                  if ( _feePerHourFourWheelers != null)
                    Text('(₹$_feePerHourFourWheelers/hr)',style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            
                          ),),
                  
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isFourWheeler == false,
                    onChanged: (value) {
                      setState(() {
                        if (_isFourWheeler == false) {
                          _isFourWheeler = null; // Deselect if already selected
                          _enteredVehicleType = '';
                        } else {
                          _isFourWheeler = false; // Select if not already selected
                          _enteredVehicleType = 'Two Wheeler';
                        }
                      });
                    },
                  ),
                  Text('Two Wheeler', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 140),
                  if ( _feePerHourTwoWheelers != null)
                    Text('(₹${_feePerHourTwoWheelers}/hr)',style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            
                          ),),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Entry Time:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2),
              Text('Select the Entry Time'),
              SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 12, // Change this as per your requirement
                  itemBuilder: (BuildContext context, int index) {
                    final now = DateTime.now();
                    DateTime currentTime =
                        now.subtract(Duration(minutes: now.minute % 15)).add(Duration(minutes: 15));
                    DateTime time = currentTime.add(Duration(minutes: 15 * index));
                    final formattedTime = DateFormat('h:mm a').format(time);
                    return _buildTimeSlotWidget(formattedTime, index);
                  },
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _bookParking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff567DF4),
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(
                    fontFamily: 'Readex Pro',
                    color: Colors.white,
                    fontSize: 17,
                    letterSpacing: 0,
                  ),
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
