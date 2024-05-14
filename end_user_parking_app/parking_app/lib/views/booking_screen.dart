import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for DateFormat
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parking_app/views/confirmation.dart';

class BookingScreen extends StatefulWidget {
  final int spaceId;
  final String spaceName;

  const BookingScreen({Key? key, required this.spaceId, required this.spaceName}) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late TextEditingController _vehicleNumberController;
  String? _enteredVehicleNumber;
  late DateTime _selectedTime;
  String _enteredVehicleType = ''; // Add vehicle type variable
  bool _isTwoWheeler = false;
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
        _isTwoWheeler = vehicleNumber.length == 2;
      });
      _vehicleNumberController.clear(); // Clear the text field
    }
  }

  void _fetchParkingFees() async {
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('PARKING SPACES').doc(widget.spaceId.toString()).get();
    if (snapshot.exists) {
      setState(() {
        _feePerHourFourWheelers = snapshot['fee_ph_four']?.toDouble();
        _feePerHourTwoWheelers = snapshot['fee_ph_two']?.toDouble();
       // Set feesLoaded to true after fetching fees
      });
    }
  } catch (e) {
    print('Error fetching parking fees: $e');
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
    if (_enteredVehicleNumber != null &&
        _enteredVehicleNumber!.isNotEmpty &&
        _selectedTime != null &&
        _enteredVehicleType.isNotEmpty) {
      // Check if vehicle type is selected
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
            'Please enter a VEHCILE NUMBER , Choose a VEHICLE TYPE and select ENTRY TIME!!!.',
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
                  Text('Four Wheeler', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  if ( _feePerHourFourWheelers != null)
                    Text('(${_feePerHourFourWheelers}/hour)'),
                  
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
                  SizedBox(width: 8),
                  if ( _feePerHourTwoWheelers != null)
                    Text('(${_feePerHourTwoWheelers}/hour)'),
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
