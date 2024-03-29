import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingArea {
  final String name;
  final double rating;
  final String workingTime;

  ParkingArea({
    required this.name,
    required this.rating,
    required this.workingTime,
  });
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<List<ParkingArea>> parkingAreas;

  @override
  void initState() {
    super.initState();
    parkingAreas = fetchParkingAreas();
  }

  Future<List<ParkingArea>> fetchParkingAreas() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('PARKING SPACES')
        .get();

    List<ParkingArea> areas = [];
    querySnapshot.docs.forEach((doc) {
      areas.add(ParkingArea(
        name: doc['space_name'],
        rating: doc['rating'].toDouble(),
        workingTime: doc['working_time'],
      ));
    });

    return areas;
  }

  void navigateToParkingDetailsPage(ParkingArea area) {
    // Navigate to parking details page
    // Example:
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ParkingDetailsPage(area: area),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Parking Areas'),
      ),
      body: FutureBuilder<List<ParkingArea>>(
        future: parkingAreas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<ParkingArea> areas = snapshot.data ?? [];
            return ListView(
              children: areas.map((area) {
                return GestureDetector(
                  onTap: () {
                    navigateToParkingDetailsPage(area);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Rating: ${area.rating}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              'Working Time: ${area.workingTime}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Go back to the previous page
                Navigator.pop(context);
              },
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
