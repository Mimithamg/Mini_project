import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:parking_app/views/near_by_location.dart';
import 'package:parking_app/views/search_page.dart';
import 'package:parking_app/views/search_bar.dart';
import 'package:parking_app/views/spot_details.dart';

class HomePage extends StatelessWidget {
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              child: content(),
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
                //ElevatedButton(
                // onPressed: () {
                //getDocuments();
                // Handle Search option
                // Navigate to search screen or perform related actions
                //},

                //child: Text('Search'),
                //),
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

  Widget content() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(10.5276, 76.2144),
        initialZoom: 15,
        interactionOptions:
            const InteractionOptions(flags: ~InteractiveFlag.doubleTapZoom),
      ),
      children: [
        OpenStreetMapTileLater,
      ],
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
      await FirebaseAuth.instance.signOut();
      // Redirect to the login page or any other desired page
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // Handle error
      print('Error logging out: $e');
      // Optionally, display an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out. Please try again.'),
        ),
      );
    }
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

TileLayer get OpenStreetMapTileLater => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet,flutter_map.example',
    );
