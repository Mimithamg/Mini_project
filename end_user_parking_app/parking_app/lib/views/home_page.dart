import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:parking_app/views/booking_screen.dart';
import 'package:parking_app/views/nearlocation.dart';
import 'package:parking_app/views/parking_area.dart';
import 'package:parking_app/views/parkingdetailsscreen.dart';
import 'package:parking_app/views/search_page.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController mapController;
  late LatLng _initialPosition =  LatLng(10.525423, 76.213470);


  final String _mapStyleString = '''
[
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#9c9c9c"

      }
    ]
  },

]
''';

  Future<List<QueryDocumentSnapshot>> _getParkingSpots() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('PARKING SPACES').get();
    return querySnapshot.docs;
  }

 List<Marker> _createMarkers(List<QueryDocumentSnapshot> parkingSpots) {
  return parkingSpots.map((doc) {
    double latitude = doc['location'].latitude;
    double longitude = doc['location'].longitude;
    String name = doc['space_name'];
    int availabilityTwoWheelers = doc['availability_two'];
    int availabilityFourWheelers = doc['availability_four'];
    
    // Create the marker icon for four-wheelers
    BitmapDescriptor carIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    // Create the marker icon for two-wheelers
    double hue =BitmapDescriptor.hueBlue;
    // Build the info window content with parking spot name and availability
    BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarkerWithHue(hue);
    // Customize the snippet with symbols for four-wheelers and two-wheelers
    

    ParkingArea area = ParkingArea(
      name: name, 
      rating: doc['rating'].toDouble(),
      workingTime: doc['working_time'],
      availabilityTwoWheelers: availabilityTwoWheelers,
      availabilityFourWheelers: availabilityFourWheelers,
      feePerHourTwoWheelers: doc['fee_ph_two'].toDouble(),
      feePerHourFourWheelers: doc['fee_ph_four'].toDouble(),
      address: doc['address'],
      isOpen: _checkOpenStatus(doc['working_time']), // You can set this based on some logic
      latitude: latitude,
      longitude: longitude,
      space_id:doc['space_id'],
      imageUrl: doc['image'],
    );

    return Marker(
      markerId: MarkerId(name),
      position: LatLng(latitude, longitude),
      icon: markerIcon,
      infoWindow: InfoWindow(
        title: name,
        
        onTap: () {
          // Handle tap on info window content here
          // You can navigate to ParkingDetailsScreen or do any other action
          _onMarkerTapped(context,area);
        },// Display availability in the info window
      ),
      onTap: () {
        // Navigate to ParkingDetailsScreen with the ParkingArea object
        _onMarkerTapped(context,area);
      }
      
    );
  }).toList();
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
  
void _onMarkerTapped(BuildContext context, ParkingArea area) {
  double _dragInitialPosition = 0;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return GestureDetector(
        onVerticalDragDown: (details) {
          _dragInitialPosition = details.globalPosition.dy;
        },
        onVerticalDragUpdate: (details) {
          double deltaY = details.globalPosition.dy - _dragInitialPosition;
          if (deltaY > 0) {
            Navigator.pop(context);
          }
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  area.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                Row(
                  children: [
                    Text('Rating: '),
                    // Display rating as stars
                    RatingBar.builder(
                      initialRating: area.rating,
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
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${area.rating}', // Display rating as number
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                
                Row(
                  children: [
                    Column(
                      children: [
                        Icon(
                          Icons.directions_car,
                          color: Colors.black,
                          size: 40,
                        ),
                        Text(
                          '${area.availabilityFourWheelers}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: area.availabilityFourWheelers < 5 ? Colors.red : Colors.green,
                          ),
                        ),
                        Text(
                          '₹${area.feePerHourFourWheelers}/hr',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 50),
                    Column(
                      children: [
                        Icon(
                          Icons.motorcycle,
                          color: Colors.black,
                          size: 40,
                        ),
                        Text(
                          '${area.availabilityTwoWheelers}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: area.availabilityTwoWheelers < 5 ? Colors.red : Colors.green,
                          ),
                        ),
                        Text(
                          '₹${area.feePerHourTwoWheelers}/hr',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 3),
                Text(
                  '${area.address}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Row(
                  children: [
                    Text(
                      area.isOpen ? 'OPEN' : 'CLOSED',
                      style: TextStyle(
                        color: area.isOpen ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${area.workingTime}',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _launchMaps(area.latitude, area.longitude);
                      }, style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Background color set to white
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min, // To make the button only as wide as its children
                          children: [
                            Icon(
                              Icons.directions,
                              color: Colors.blue, // Icon color set to blue
                            ),
                            SizedBox(width: 8), // Add some space between icon and text
                            Text(
                              'Directions',
                              style: TextStyle(
                                color: Colors.blue, // Text color set to blue
                              ),
                            ),
                          ],
                        ),
                     
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>ParkingDetailsScreen(area: area,data:{}),
                          ),
                        );
                      },
                       style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Background color set to white
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min, // To make the button only as wide as its children
                          children: [
                            Icon(
                              Icons.details,
                              color: Colors.blue, // Icon color set to blue
                            ),
                            SizedBox(width: 8), // Add some space between icon and text
                            Text(
                              'More Details',
                              style: TextStyle(
                                color: Colors.blue, // Text color set to blue
                              ),
                            ),
                          ],
                        ),
                      
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingScreen(
                                    spaceId: area.space_id,
                                    spaceName: area.name,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff567DF4),
                              padding: EdgeInsets.symmetric(horizontal: 50),
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
                  ],
                ),
                SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                       style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Background color set to white
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min, // To make the button only as wide as its children
                          children: [
                            
                            SizedBox(width: 8), // Add some space between icon and text
                            Text(
                              'Close',
                              style: TextStyle(
                                color: Colors.red, // Text color set to blue
                              ),
                            ),
                          ],
                        ),
                     
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


  void _launchMaps(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }



  Future<void> _getCurrentLocation(BuildContext context) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }


@override
void initState() {
  super.initState();
  Future.delayed(Duration.zero, () {
    _showLocationPermissionDialog(context);
  });
}



 void _showLocationPermissionDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Permission'),
          content: Text('Do you want to turn on location services?'),
          actions: <Widget>[
            ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 7, horizontal: 5),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text(
                'Yes',
                style: TextStyle(
                  fontFamily: 'Readex Pro',
                  color: Colors.blue,
                  fontSize: 17,
                  letterSpacing: 0,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _initialPosition = LatLng(10.525423, 76.213470);
                });
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

 void _animateToLocation(ParkingArea area) {
    // Animate the map to the specified location
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(area.latitude, area.longitude),
        16.9,
      ),
    );
    _onMarkerTapped(context, area);
  }
  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
        title: Text('PARK.IN'),
      ),
      drawer: Drawer(
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 212, 214, 213),
                  ),
                  child: Text('Welcome'),
                ),
                ListTile(
                  title: Text('Profile'),
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => ParkingDetailsScreen(),
                    //   ),
                    // );
                  },
                ),
                ListTile(
                  title: Text('History'),
                ),
                Divider(),
                ListTile(
                  title: Text('Logout'),
                  onTap: () {
                    confirmLogout(context);
                  },
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    confirmLogout(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: _initialPosition == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: FutureBuilder<List<QueryDocumentSnapshot>>(
                    future: _getParkingSpots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        List<QueryDocumentSnapshot> parkingSpots = snapshot.data ?? [];
                        return GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _initialPosition,
                            zoom: 15,
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            mapController = controller;
                            controller.setMapStyle(_mapStyleString);
                          },
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          markers: Set<Marker>.of(_createMarkers(parkingSpots)),
                          
                          style: JsonEncoder().convert(_mapStyleString),
                        );
                        
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                                final selectedParkingArea  = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => NearbyLocationsPage()),
                         );
                         if (selectedParkingArea != null) {
                          _animateToLocation(selectedParkingArea);
                        }

                        },child: const Row(
                          mainAxisSize: MainAxisSize.min, // To make the button only as wide as its children
                          children: [
                            Icon(
                              Icons.near_me_sharp,
                              color: Colors.blue, // Icon color set to blue
                            ),
                            SizedBox(width: 8), // Add some space between icon and text
                            Text(
                              'Nearby Parking',
                              style: TextStyle(
                                color: Colors.blue, // Text color set to blue
                              ),
                            ),
                          ],
                        ),
                        
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final selectedParkingArea = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SearchPage()),
                          );
                          if (selectedParkingArea != null) {
                            _animateToLocation(selectedParkingArea);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Background color set to white
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min, // To make the button only as wide as its children
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.blue, // Icon color set to blue
                            ),
                            SizedBox(width: 8), // Add some space between icon and text
                            Text(
                              '  Search  ',
                              style: TextStyle(
                                color: Colors.blue, // Text color set to blue
                              ),
                            ),
                          ],
                        ),
                      )

                    ],
                  ),
                ),
              ],
            ),
    );
  }
}


  void confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                logout(context); // Logout the user
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void logout(BuildContext context) async {
    try {
      // Add your logout functionality here
    } catch (e) {
      print('Error logging out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out. Please try again.'),
        ),
      );
    }
  }