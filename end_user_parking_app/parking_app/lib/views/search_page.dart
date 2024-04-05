import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingArea {
  final String name;
  final double rating;
  final String workingTime;
  final int availabilityTwoWheelers;
  final int availabilityFourWheelers;
  final double feePerHourTwoWheelers;
  final double feePerHourFourWheelers;

  ParkingArea({
    required this.name,
    required this.rating,
    required this.workingTime,
    required this.availabilityTwoWheelers,
    required this.availabilityFourWheelers,
    required this.feePerHourTwoWheelers,
    required this.feePerHourFourWheelers,
  });
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<List<ParkingArea>> parkingAreas;
  late List<ParkingArea> allAreas = []; // Original list of all parking areas
  late List<ParkingArea> filteredAreas = [];

  @override
  void initState() {
    super.initState();
    parkingAreas = fetchParkingAreas();
  }

  Future<List<ParkingArea>> fetchParkingAreas() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('PARKING SPACES').get();

    List<ParkingArea> areas = [];
    querySnapshot.docs.forEach((doc) {
      areas.add(ParkingArea(
        name: doc['space_name'],
        rating: doc['rating'].toDouble(),
        workingTime: doc['working_time'],
        availabilityTwoWheelers: doc['availability_two'].toInt(),
        availabilityFourWheelers: doc['availability_four'].toInt(),
        feePerHourTwoWheelers: doc['fee_ph_two'].toDouble(),
        feePerHourFourWheelers: doc['fee_ph_four'].toDouble(),
      ));
    });

    allAreas = List.of(areas); // Store original list
    return areas;
  }

  void navigateToParkingDetailsPage(ParkingArea area) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParkingDetailsPage(area: area),
      ),
    );
  }

  void filterSearchResults(String query) {
    List<ParkingArea> searchResults = [];
    searchResults.addAll(allAreas); // Use original list for filtering
    if (query.isNotEmpty) {
      List<ParkingArea> dummySearchList = [];
      searchResults.forEach((item) {
        if (item.name.toLowerCase().contains(query.toLowerCase())) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Parking Areas'),
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
                hintText: "Search for parking areas",
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
                    children: filteredAreas.map((area) {
                      return GestureDetector(
                        onTap: () {
                          navigateToParkingDetailsPage(area);
                        },
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          padding: EdgeInsets.all(16),
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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/parking.png'),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      area.name,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (index) => Icon(
                                          Icons.star,
                                          size: 16,
                                          color: index < area.rating
                                              ? Colors.amber
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Working Time: ${area.workingTime}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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

class ParkingDetailsPage extends StatelessWidget {
  final ParkingArea area;

  ParkingDetailsPage({required this.area});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(area.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              'assets/parking.png',
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16),
            Text(
              'Rating: ${area.rating}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(
              'Working Time: ${area.workingTime}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(
              'Available Spaces for Four Wheelers: ${area.availabilityFourWheelers}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(
              'Available Spaces for Two Wheelers: ${area.availabilityTwoWheelers}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(
              'Fee per Hour for Two Wheelers: \$${area.feePerHourTwoWheelers}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(
              'Fee per Hour for Four Wheelers: \$${area.feePerHourFourWheelers}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Handle direction button
              },
              icon: Icon(Icons.directions, color: Colors.green),
              label: Text(
                'Get Directions',
                style: TextStyle(color: Colors.green),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
