import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:parking_app/views/booking_screen.dart';
import 'package:parking_app/views/parking_area.dart';
import 'package:parking_app/views/parkingdetailsscreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class NearbyLocationsPage extends StatefulWidget {
  @override
  _NearbyLocationsPageState createState() => _NearbyLocationsPageState();
}

class _NearbyLocationsPageState extends State<NearbyLocationsPage> {
  late Future<List<ParkingArea>> parkingAreas= Future.value([]);
  late List<ParkingArea> allAreas = []; // Original list of all parking areas
  late List<ParkingArea> filteredAreas = [];
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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }
  void _getCurrentLocation() async {
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
    setState(() {
      parkingAreas = fetchParkingAreas(); 
       _currentPosition = position;// Fetch parking areas after getting the user's location
    });
  } catch (e) {
    print('Error getting current location: $e');
  }
}

  Future<List<ParkingArea>> fetchParkingAreas() async {
  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('PARKING SPACES').get();

  List<ParkingArea> areas = [];
  querySnapshot.docs.forEach((doc) {
    double distanceInMeters = Geolocator.distanceBetween(
      _currentPosition.latitude,
      _currentPosition.longitude,
      doc['location'].latitude,
      doc['location'].longitude,
    );

    // Check if the parking spot is within 1km radius (1000 meters)
    if (distanceInMeters <= 1000) {
      areas.add(ParkingArea(
        name: doc['space_name'],
        rating: doc['rating'].toDouble(),
        workingTime: doc['working_time'],
        address: doc['address'],
        availabilityTwoWheelers: doc['availability_two'].toInt(),
        availabilityFourWheelers: doc['availability_four'].toInt(),
        feePerHourTwoWheelers: doc['fee_ph_two'].toDouble(),
        feePerHourFourWheelers: doc['fee_ph_four'].toDouble(),
        isOpen: _checkOpenStatus(doc['working_time']),
        latitude: doc['location'].latitude,
        longitude: doc['location'].longitude,
        space_id:doc['space_id'],
        imageUrl: doc['image'],
      ));
    }
  });

  allAreas = List.of(areas); // Store original list
  return areas;
}

  void _filterParkingAreas(double userLatitude, double userLongitude) {
    // Filter parking areas within 1 km radius
    filteredAreas = allAreas.where((area) {
      double distance = Geolocator.distanceBetween(
        userLatitude,
        userLongitude,
        area.latitude,
        area.longitude,
      );

      // 1 km = 1000 meters
      return distance <= 1000;
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

  void navigateToParkingDetailsPage(ParkingArea area) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParkingDetailsScreen(area: area,data:{} ),
      ),
    );
  }

  void filterSearchResults(String query) {
    List<ParkingArea> searchResults = [];
    searchResults.addAll(allAreas); // Use original list for filtering
    if (query.isNotEmpty) {
      List<ParkingArea> dummySearchList = [];
      searchResults.forEach((item) {
        if (item.address.toLowerCase().contains(query.toLowerCase())) {
          // Check address instead of name
          dummySearchList.add(item);
        }
      });
      setState(() {
        filteredAreas.clear();
        filteredAreas.addAll(dummySearchList);
      });
      return;
    } else {
      setState(() {
        filteredAreas.clear();
        filteredAreas.addAll(searchResults);
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Parking Areas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                filterSearchResults(value);
              },
              decoration: InputDecoration(
                labelText: "Search",
                hintText: "Search for Nearby parking areas",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ParkingArea>>(
              future: parkingAreas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<ParkingArea> areas = snapshot.data ?? [];
                  filteredAreas = areas; // Assign initial areas
                  return ListView(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    children: filteredAreas.map((area) {
                      return GestureDetector(
                        onTap: () {
                          navigateToParkingDetailsPage(area);
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [ 
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(area.imageUrl),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        area.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on), // Location icon
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              area.address,
                                              // overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
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
                                            itemPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 2.0),
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
                                            '${area.rating}',
                                            // Display rating as number
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.motorcycle),
                                          // Bike icon
                                          SizedBox(width: 8),
                                          Flexible(
                                            // Wrap with Flexible
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Available:',
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                Text(
                                                  '${area.availabilityTwoWheelers}',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: area.availabilityTwoWheelers < 5
                                                        ? Colors.red
                                                        : Colors.green,
                                                  ),
                                                ),
                                                Text(
                                                  'Fee/hr: ₹${area.feePerHourTwoWheelers}',
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Icon(Icons.directions_car),
                                          // Car icon
                                          SizedBox(width: 8),
                                          Flexible(
                                            // Wrap with Flexible
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Available:',
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                Text(
                                                  '${area.availabilityFourWheelers}',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: area.availabilityFourWheelers < 5
                                                        ? Colors.red
                                                        : Colors.green,
                                                  ),
                                                ),
                                                Text(
                                                  'Fee/hr: ₹${area.feePerHourFourWheelers}',
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            area.isOpen ? 'OPEN' : 'CLOSED',
                                            style: TextStyle(
                                              color: area.isOpen
                                                  ? Colors.green
                                                  : Colors.red,
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
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  width: 55,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(Icons.directions),
                                    color: Colors.white,
                                    onPressed: () {
                                      _navigateToLocation(
                                          area.latitude, area.longitude);
                                    },
                                  ),
                                ),
                                

                              ],
                            ),
                            SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context, area);
                                    },
                                     style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Background color set to white
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min, // To make the button only as wide as its children
                          children: [
                            Icon(
                              Icons.map_outlined,
                              color: Colors.blue, // Icon color set to blue
                            ),
                            SizedBox(width: 8), // Add some space between icon and text
                            Text(
                              'Show On Map',
                              style: TextStyle(
                                color: Colors.blue, // Text color set to blue
                              ),
                            ),
                          ],
                        ),
                                   
                                  ),
                                   SizedBox(width:25),
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
                                ],
                              ),]
                          ),
                        ),
                      ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
