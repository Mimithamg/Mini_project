import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator package
import 'package:parking_app/views/near_by_location.dart';
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

  void _onMarkerTapped(ParkingArea area) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParkingDetailsScreen(
          area: area,
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

  List<Marker> _getMarkers() {
    return [
      Marker(
        markerId: MarkerId('thrissur1'),
        position: LatLng(10.552945, 76.222011),
        infoWindow: InfoWindow(title: 'gect cse parking'),
        onTap: () {
          _onMarkerTapped(
            ParkingArea(
              name: 'gect cse parking',
              address: 'Address of gect cse parking',
              workingTime: '9 am to 7 pm',
              availabilityFourWheelers: 10,
              availabilityTwoWheelers: 15,
              feePerHourFourWheelers: 20,
              feePerHourTwoWheelers: 15,
              rating: 4,
            ),
          );
        },
      ),
      Marker(
        markerId: MarkerId('thrissur2'),
        position: LatLng(10.57666, 76.20752),
        infoWindow: InfoWindow(title: 'mimis parking'),
        onTap: () {
          _onMarkerTapped(
            ParkingArea(
              name: 'mimis parking',
              address: 'Address of mimis parking',
              workingTime: '8 am to 10 pm',
              availabilityFourWheelers: 5,
              availabilityTwoWheelers: 20,
              feePerHourFourWheelers: 25,
              feePerHourTwoWheelers: 10,
              rating: 3.5,
            ),
          );
        },
      ),
      Marker(
        markerId: MarkerId('thrissur3'),
        position: LatLng(10.6074751, 76.148504),
        infoWindow: InfoWindow(title: 'urmis parking'),
        onTap: () {
          _onMarkerTapped(
            ParkingArea(
              name: 'urmis parking',
              address: 'Address of urmis parking',
              workingTime: '7 am to 11 pm',
              availabilityFourWheelers: 8,
              availabilityTwoWheelers: 18,
              feePerHourFourWheelers: 3,
             rating: 3.5, feePerHourTwoWheelers: 20,
            ),
          );
        },
      )
    ];
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
                  child: GoogleMap(
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
                     markers: Set<Marker>.of(_getMarkers()),
                      style: JsonEncoder().convert(_mapStyleString),
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
}