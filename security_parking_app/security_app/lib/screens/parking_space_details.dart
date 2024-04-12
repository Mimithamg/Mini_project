import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParkingSpaceDetailsScreen extends StatelessWidget {
  final String spaceId;

  const ParkingSpaceDetailsScreen({Key? key, required this.spaceId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parking Space Details'),
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: _fetchParkingSpace(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data found for ID: $spaceId'));
          } else {
            var parkingSpaceData = snapshot.data!.docs.first.data();
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parking Space ID: $spaceId',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('Address: ${parkingSpaceData['address']}'),
                  Text(
                      'Availability (Four-Wheelers): ${parkingSpaceData['availability_four']}'),
                  Text(
                      'Availability (Two-Wheelers): ${parkingSpaceData['availability_two']}'),
                  Text(
                      'Capacity (Four-Wheelers): ${parkingSpaceData['capacity_four']}'),
                  Text(
                      'Capacity (Two-Wheelers): ${parkingSpaceData['capacity_two']}'),
                  Text(
                      'Parking Fee per Hour (Four-Wheelers): ${parkingSpaceData['fee_ph_four']}'),
                  Text(
                      'Parking Fee per Hour (Two-Wheelers): ${parkingSpaceData['fee_ph_two']}'),
                  Text('Location: ${parkingSpaceData['location']}'),
                  Text('Rating: ${parkingSpaceData['rating']}'),
                  Text('Space Name: ${parkingSpaceData['space_name']}'),
                  Text('Working Time: ${parkingSpaceData['working_time']}'),
                  // Add more details as needed
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _fetchParkingSpace() async {
    return FirebaseFirestore.instance
        .collection('PARKING SPACES')
        .where('space_id', isEqualTo: int.parse(spaceId))
        .get();
  }
}
