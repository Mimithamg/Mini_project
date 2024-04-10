import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchBarr extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firestore Data'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('PARKING SPACES').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic>? data = document.data()
                  as Map<String, dynamic>?; // Cast to Map<String, dynamic>?
              if (data != null && data.containsKey('capacity_two')) {
                String capacityTwo = document['capacity_two'].toString();
                return ListTile(
                  title: Text(document['space_name'].toString()),
                  subtitle: Text(capacityTwo),
                  // Add more widgets to display other fields as needed
                );
              } else {
                // Handle the case where 'capacity_two' field is missing
                return ListTile(
                  title: Text(document['space_name'].toString()),
                  subtitle: Text('Capacity not available'),
                  // Add more widgets to display other fields as needed
                );
              }
            },
          );
        },
      ),
    );
  }
}
