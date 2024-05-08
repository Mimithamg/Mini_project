import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:parking_app/views/parking_area.dart';
import 'package:parking_app/views/search_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
class ParkingDetailsScreen extends StatefulWidget {
  final ParkingArea area;
  const ParkingDetailsScreen({super.key, required this.area, required Map<String, dynamic> data});

  @override
  State<ParkingDetailsScreen> createState() => _ParkingDetailsScreenState();
}

class _ParkingDetailsScreenState extends State<ParkingDetailsScreen> {


  void _navigateToLocation(double latitude, double longitude) async {
    String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      print('Could not launch $googleMapsUrl');
    }
  }
  @override
  Widget build(BuildContext context) {
    TimeOfDay _parseTimeString(String timeString) {
      bool isPM = timeString.toLowerCase().contains('pm');
      List<String> parts =
          timeString.replaceAll(RegExp(r'[^0-9]'), '').split('');
      int hour = int.parse(parts[0]);
      if (isPM && hour != 12) {
        hour += 12;
      } else if (!isPM && hour == 12) {
        hour = 0;
      }
      int minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      return TimeOfDay(hour: hour, minute: minute);
    }

    // Parse the workingTime string into TimeOfDay objects
    List<String> workingHours = widget.area.workingTime.split(' to ');
    String openingTimeString = workingHours[0].trim(); // "9 am"
    String closingTimeString = workingHours[1].trim(); // "7 pm"

    // Parse opening time
    TimeOfDay openingTime = _parseTimeString(openingTimeString);

    // Parse closing time
    TimeOfDay closingTime = _parseTimeString(closingTimeString);

    // Get the current time
    DateTime now = DateTime.now();
    TimeOfDay currentTime = TimeOfDay.fromDateTime(now);

    // Check if the current time is within the working hours
    bool isOpen = currentTime.hour > openingTime.hour &&
        currentTime.hour < closingTime.hour;

    // Build the text accordingly
    String openCloseText = isOpen
        ? 'Open until ${closingTime.format(context)}'
        : 'Closed. Opens at ${openingTime.format(context)}';

    // Function to parse time string to TimeOfDay

    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.area.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                width: screenSize.width,
                child: Container(
                  width: screenSize.width,
                  height:
                      screenSize.height * 0.28, // Adjust the height as needed
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/parking.png',
                      width:
                          screenSize.width, // Image width set to screen width
                      height: screenSize.height *
                          0.3, // Image height set to container height
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Generated code for this Row Widget...
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 306,
                    height: 81,
                    decoration: BoxDecoration(),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                Icons.star,
                                size: 16,
                                color: index < widget.area.rating
                                    ? Colors.amber
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          Text(
                            openCloseText,
                            style: TextStyle(
                              fontFamily: 'Readex Pro',
                              letterSpacing: 0,
                            ),
                          ),
                          Text(
                            '${widget.area.availabilityFourWheelers > 1 ? "Available for four-wheelers" : "Available only one slot left"}',
                            style: TextStyle(
                              fontFamily: 'Readex Pro',
                              letterSpacing: 0,
                            ),
                          ),
                          Text(
                            '${widget.area.availabilityTwoWheelers > 1 ? "Available for two wheelers" : "Available only one slot left"}',
                            style: TextStyle(
                              fontFamily: 'Readex Pro',
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _navigateToLocation(
                                            widget.area.latitude, widget.area.longitude);
                    },
                    icon: Icon(
                      Icons.directions_rounded,
                      color: Color(0xff567DF4),
                      size: 50,
                    ),
                  )
                ],
              ),

              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: 516,
                      height: 58,
                      decoration: BoxDecoration(),
                      child: Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: AlignmentDirectional(-1, 0),
                              child: Icon(
                                Icons.location_pin,
                                color: Colors.grey,
                                size: 34,
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(0, 0),
                              child: Text(
                                '${widget.area.address ?? "Address not available"}',
                                style: TextStyle(
                                  fontFamily: 'Readex Pro',
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 516,
                      height: 58,
                      decoration: BoxDecoration(),
                      child: Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: AlignmentDirectional(-1, 0),
                              child: Icon(
                                Icons.access_time_outlined,
                                color: Colors.grey,
                                size: 34,
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(0, 0),
                              child: Text(
                                openCloseText,
                                style: TextStyle(
                                  fontFamily: 'Readex Pro',
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            // Align(
                            //   alignment: AlignmentDirectional(0, 0),
                            //   child: Text(
                            //     'closes 10 pm',
                            //     style: TextStyle(
                            //       fontFamily: 'Readex Pro',
                            //       letterSpacing: 0,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 516,
                      height: 58,
                      decoration: BoxDecoration(),
                      child: Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: AlignmentDirectional(-1, 0),
                              child: Icon(
                                Icons.currency_rupee,
                                color: Colors.grey,
                                size: 34,
                              ),
                            ),
                            Column(
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Text(
                                    'for four Wheelers: \$${widget.area.feePerHourFourWheelers} ,',
                                    style: TextStyle(
                                      fontFamily: 'Readex Pro',
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Text(
                                    'for Two Wheelers: \$${widget.area.feePerHourTwoWheelers}',
                                    style: TextStyle(
                                      fontFamily: 'Readex Pro',
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 516,
                      height: 58,
                      decoration: BoxDecoration(),
                      child: Align(
                        alignment: AlignmentDirectional(0, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: AlignmentDirectional(-1, 0),
                              child: Icon(
                                Icons.local_parking,
                                color: Colors.grey,
                                size: 34,
                              ),
                            ),
                            Column(
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Text(
                                    '${widget.area.availabilityFourWheelers > 1 ? "Available for four-wheelers" : "Available only one slot left"}',
                                    style: TextStyle(
                                      fontFamily: 'Readex Pro',
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Text(
                                    '${widget.area.availabilityTwoWheelers > 1 ? "Available for two-wheelers" : "Available only one slot left"}',
                                    style: TextStyle(
                                      fontFamily: 'Readex Pro',
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                              print('Button pressed ...');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff567DF4),
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: Text(
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
                            child: Text(
                              'directions',
                              style: TextStyle(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                fontSize: 16,
                                letterSpacing: 0,
                              ),
                            ),
                          
                          ),
                        ),
                      ],
                    ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

void _launchMaps() async {
    final latitude = widget.area.latitude; // Replace with actual latitude
    final longitude = widget.area.longitude; // Replace with actual longitude
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}