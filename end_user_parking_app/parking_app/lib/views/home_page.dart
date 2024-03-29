import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parking_app/views/search_bar.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchBarr(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('History'),
                  onTap: () {
                    // Handle navigation to option 2 page
                  },
                ),
                Divider(),
                ListTile(
                  title: Text('Logout'),
                  onTap: () {
                    // Handle logout
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
                    // Handle logout
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              // Add your Google Map widget here
              color: Colors.grey, // Placeholder color
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showLocationPermissionDialog(context);
                    // Handle Nearby Spaces option
                    // Navigate to nearby spaces screen or perform related actions
                  },
                  child: Text('Nearby Spaces'),
                ),
                ElevatedButton(
                  onPressed: () {
                    getDocuments();
                    // Handle Search option
                    // Navigate to search screen or perform related actions
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

  void _showLocationPermissionDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Permission'),
          content: Text('Do you want to turn on location services?'),
          actions: <Widget>[
            TextButton(
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
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _getCurrentLocation(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled, prompt the user to enable them.
      _showLocationServiceDisabledDialog(context);
    } else {
      // Location services are enabled, attempt to get the current location.
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        print('Current Location: ${position.latitude}, ${position.longitude}');
      } catch (e) {
        print('Error getting current location: $e');
      }
    }
  }

  void _showLocationServiceDisabledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Location Service Disabled'),
          content: Text('Please enable location services to continue.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Optionally navigate to location settings
                //_navigateToLocationSettings();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> getDocuments() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(
              'PARKING SPACES') // Replace 'your_collection_name' with your collection name
          .get();
      // Iterate through the documents
      querySnapshot.docs.forEach((doc) {
        print(doc.data()); // Access document data
      });
    } catch (e) {
      print("Error: $e");
    }
  }
}
