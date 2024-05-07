import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:parking_app/views/near_by_location.dart';
import 'package:parking_app/views/nearlocation.dart';
import 'package:parking_app/views/parking_area.dart';
import 'package:parking_app/views/parkingdetailsscreen.dart';
import 'package:parking_app/views/search_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController mapController;
  late LatLng _initialPosition;

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
    BitmapDescriptor bikeIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

    // Build the info window content with parking spot name and availability
    String infoWindowText = '''
    
    Available 2 Wheelers: $availabilityTwoWheelers
    Available 4 Wheelers: $availabilityFourWheelers
    ''';

    // Customize the snippet with symbols for four-wheelers and two-wheelers
    String snippet = '''
    🚗: $availabilityFourWheelers 
    🏍️: $availabilityTwoWheelers 
    ''';

    ParkingArea area = ParkingArea(
      name: name, 
      rating: doc['rating'].toDouble(),
      workingTime: doc['working_time'],
      availabilityTwoWheelers: availabilityTwoWheelers,
      availabilityFourWheelers: availabilityFourWheelers,
      feePerHourTwoWheelers: doc['fee_ph_two'].toDouble(),
      feePerHourFourWheelers: doc['fee_ph_four'].toDouble(),
      address: doc['address'],
      isOpen: true, // You can set this based on some logic
      latitude: latitude,
      longitude: longitude,
    );

    return Marker(
      markerId: MarkerId(name),
      position: LatLng(latitude, longitude),
      icon: availabilityFourWheelers > 0
          ? carIcon
          : availabilityTwoWheelers > 0
              ? bikeIcon
              : BitmapDescriptor.defaultMarker,
      infoWindow: InfoWindow(
        title: name,
        snippet: snippet, 
        onTap: () {
          // Handle tap on info window content here
          // You can navigate to ParkingDetailsScreen or do any other action
          _onMarkerTapped(area);
        },// Display availability in the info window
      ),
      onTap: () {
        // Navigate to ParkingDetailsScreen with the ParkingArea object
        _onMarkerTapped(area);
      }
      
    );
  }).toList();
}



  void _onMarkerTapped(ParkingArea area) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParkingDetailsScreen(
          area: area, data: {}, 
        ),
      ),
    );
  }

  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high); // Fetch the current position
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }

@override
void initState() {
  super.initState();
   _getUserLocation();
   // Fetch user's current location when the widget initializes
  setState(() {
    _initialPosition = LatLng(10.525423, 76.213470); // Thrissur's coordinates
  });
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NearbyLocationsPage()),
                          );
                          // Handle Nearby Spaces option
                          // Navigate to nearby spaces screen or perform related actions
                        },
                        child: const Text('Nearby Spaces'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SearchPage()),
                          );
                        },
                        child: Text('Search'),
                      ),
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