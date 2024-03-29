import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NearbyLocationsPage extends StatefulWidget {
  @override
  _NearbyLocationsPageState createState() => _NearbyLocationsPageState();
}

class _NearbyLocationsPageState extends State<NearbyLocationsPage> {
  late Position _currentPosition = Position(
    latitude: 0.0, // Provide a default latitude
    longitude: 0.0, // Provide a default longitude
    timestamp: DateTime.now(), // Provide a default timestamp
    accuracy: 0.0, // Provide a default accuracy
    altitude: 0.0, // Provide a default altitude
    altitudeAccuracy: 0.0, // Provide a default altitudeAccuracy
    heading: 0.0, // Provide a default heading
    headingAccuracy: 0.0, // Provide a default headingAccuracy
    speed: 0.0, // Provide a default speed
    speedAccuracy: 0.0, // Provide a default speedAccuracy
  );

  List<Map<String, dynamic>> _nearbyLocations = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchLocationsFromFirebase(); // Fetch locations from Firestore
  }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  void _fetchLocationsFromFirebase() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('PARKING SPACES').get();
      List<Map<String, dynamic>> locations = [];
      querySnapshot.docs.forEach((doc) {
        GeoPoint location = doc['location'];
        String name = doc['space_name'];
        locations.add({
          'name': name,
          'latitude': location.latitude,
          'longitude': location.longitude,
        });
      });
      print('Fetched locations: $locations');
      setState(() {
        _nearbyLocations = locations;
      });
    } catch (e) {
      print('Error fetching locations: $e');
    }
  }

  void _filterLocations(double radiusInMeters) {
    List<Map<String, dynamic>> filteredLocations = [];
    for (var location in _nearbyLocations) {
      double distanceInMeters = Geolocator.distanceBetween(
        _currentPosition.latitude,
        _currentPosition.longitude,
        location['latitude'],
        location['longitude'],
      );

      if (distanceInMeters <= radiusInMeters) {
        filteredLocations.add(location);
      }
    }
    setState(() {
      _nearbyLocations = filteredLocations;
    });
  }

  Widget _buildLocationList() {
    if (_nearbyLocations.isEmpty) {
      return Text('No nearby locations found.');
    } else {
      return ListView.builder(
        itemCount: _nearbyLocations.length,
        itemBuilder: (context, index) {
          final location = _nearbyLocations[index];
          return ListTile(
            title: Text(location['name']),
            subtitle: Text(
                'Latitude: ${location['latitude']}, Longitude: ${location['longitude']}'),
            onTap: () {
              // Handle tapping on a location if needed
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Locations'),
      ),
      body: _currentPosition != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Current Location: ${_currentPosition.latitude}, ${_currentPosition.longitude}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Container(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _filterLocations(100), // 100 meters radius
                        child: Text('Within 100m'),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _filterLocations(1000), // 200 meters radius
                        child: Text('Within 1km'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: _buildLocationList(),
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
