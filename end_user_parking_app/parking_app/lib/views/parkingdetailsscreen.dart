import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:parking_app/views/booking_screen.dart';
import 'package:parking_app/views/parking_area.dart';
import 'package:url_launcher/url_launcher.dart';

class ParkingDetailsScreen extends StatefulWidget {
  final ParkingArea area;
  const ParkingDetailsScreen({Key? key, required this.area, required Map<String, dynamic> data})
      : super(key: key);

  @override
  State<ParkingDetailsScreen> createState() => _ParkingDetailsScreenState();
}

class _ParkingDetailsScreenState extends State<ParkingDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    // Fetch the current time
    final now = DateTime.now();

    // Check if the current time is within the working time of the parking spot
    bool isOpen = true; // Assume open by default
    if (widget.area.workingTime != null) {
      // Parse the working time from the database (assuming it's in a suitable format)
      // Compare with the current time to determine if the parking spot is open
      isOpen = _checkOpenStatus(widget.area.workingTime);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Parking Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display name of the parking spot in bold
            Text(
              widget.area.name,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            // Display rating of the parking spot using stars
            Row(
              children: [
                RatingBar.builder(
                  initialRating: widget.area.rating,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 16,
                  itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  ignoreGestures: true,
                  onRatingUpdate: (double value) {},
                  // Disable rating changes from UI
                ),
                SizedBox(width: 8),
                Text(
                  '${widget.area.rating}', // Display rating as number
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Text(
                  widget.area.isOpen ? 'OPEN' : 'CLOSED',
                  style: TextStyle(
                    color: widget.area.isOpen ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            // Display photo of the parking spot with border decoration
            Container(
              width: double.infinity,
              height: 200.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: Colors.blue, // Border color
                  width: 2.0, // Border width
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  widget.area.imageUrl,
                  width: double.infinity,
                  height: 200.0,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            // Display location icon instead of "Address:"
            Row(
              children: [
                Icon(Icons.location_on), // Location icon
                SizedBox(width: 8),
                    Expanded( // Wrap with Expanded to prevent overflow
                  child: Text(
                    widget.area.address,
                    style: const TextStyle(
                        fontSize: 17, 
                  ),),
                ),
              ],
            ),
             SizedBox(height: 8.0),
            Row(
              children: [
                Text('OPEN - ${widget.area.workingTime}',
                style: const TextStyle(
                        fontSize: 17, 
                  )),
              ],
            ),
            SizedBox(height: 15.0),
            // Display availability of 4-wheelers and 2-wheelers
            Row(
              children: [
                Column(
                  children: [
                    const Icon(
                      Icons.directions_car,
                      color: Colors.black,
                      size: 40,
                    ),
                     SizedBox(height: 4.0),
                    Text(
                      '₹${widget.area.feePerHourFourWheelers}/hr',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                Column(children: [
                    Text(
                      '${widget.area.availabilityFourWheelers}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: widget.area.availabilityFourWheelers < 5
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                ],),
                SizedBox(width: 60),
                Column(
                  children: [
                    Icon(
                      Icons.motorcycle,
                      color: Colors.black,
                      size: 43,
                    ),
                    
                    Text(
                      '₹${widget.area.feePerHourTwoWheelers}/hr',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 20),
                Column(children: [
                    Text(
                      '${widget.area.availabilityTwoWheelers}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: widget.area.availabilityTwoWheelers < 5
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                ],),
              ],
            ),
            SizedBox(height: 30.0),
            Container(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingScreen(
                                    spaceId: widget.area.space_id,
                                    spaceName: widget.area.name,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff567DF4),
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: const Text(
                              'Book parking',
                              style: TextStyle(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                fontSize: 16,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 30), // Add space between buttons
                        Container(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                              _navigateToLocation(
                                  widget.area.latitude, widget.area.longitude);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff567DF4),
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child:const Row(
                          mainAxisSize: MainAxisSize.min, // To make the button only as wide as its children
                          children: [
                            Icon(
                              Icons.directions,
                              color: Colors.white, // Icon color set to blue
                            ),
                            SizedBox(width: 8), // Add some space between icon and text
                            Text(
                              'Directions',
                              style: TextStyle(
                                color: Colors.white, // Text color set to blue
                              ),
                            ),
                          ],
                        ),
                          ),
                        ),
                      ],
                    ))// Display whether the parking spot is open or closed
          ],
        ),
      ),
    );
  }

  bool _checkOpenStatus(String workingTime) {
    List<String> workingHours = workingTime.split(' to ');
    TimeOfDay openingTime = _parseTimeString(workingHours[0].trim());
    TimeOfDay closingTime = _parseTimeString(workingHours[1].trim());

    // Get the current time
    TimeOfDay currentTime = TimeOfDay.now();

    // Check if the current time is within the working hours
    return currentTime.hour >= openingTime.hour &&
        currentTime.hour < closingTime.hour;
  }

  TimeOfDay _parseTimeString(String timeString) {
    bool isPM = timeString.toLowerCase().contains('pm');
    List<String> parts = timeString.replaceAll(RegExp(r'[^0-9]'), '').split('');
    int hour = int.parse(parts[0]);
    if (isPM && hour != 12) {
      hour += 12;
    } else if (!isPM && hour == 12) {
      hour = 0;
    }
    int minute = parts.length > 1 ? int.parse(parts[1]) : 0;
    return TimeOfDay(hour: hour, minute: minute);
  }
  void _navigateToLocation(double latitude, double longitude) async {
    String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      print('Could not launch $googleMapsUrl');
    }
  }
}
