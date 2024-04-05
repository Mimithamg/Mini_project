import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NearbyLocationsPage extends StatefulWidget {
  @override
  _NearbyLocationsPageState createState() => _NearbyLocationsPageState();
}

class _NearbyLocationsPageState extends State<NearbyLocationsPage> {
  late Position _currentPosition = Position(
    latitude: 0.0,
    longitude: 0.0,
    timestamp: DateTime.now(),
    accuracy: 0.0,
    altitude: 0.0,
    altitudeAccuracy: 0.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
  );

  List<Map<String, dynamic>> _nearbyLocations = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchLocationsFromFirebase();
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
      return Center(
        child: Text('No nearby locations found.'),
      );
    } else {
      return ListView.builder(
        itemCount: _nearbyLocations.length,
        itemBuilder: (context, index) {
          final location = _nearbyLocations[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                title: Text(location['name']),
                subtitle: Text(
                    'Latitude: ${location['latitude']}, Longitude: ${location['longitude']}'),
                onTap: () {
                  // Handle tapping on a location if needed
                },
              ),
            ),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _currentPosition != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Current Location: ${_currentPosition.latitude}, ${_currentPosition.longitude}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              : SizedBox(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _filterLocations(100), // 100 meters radius
                  child: Text('Within 100m'),
                ),
                ElevatedButton(
                  onPressed: () => _filterLocations(
                      1000), // 1000 meters radius, changed comment to match actual radius
                  child: Text('Within 1km'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildLocationList(),
          ),
        ],
      ),
    );
  }
}
