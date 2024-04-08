import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final bool isStaff;

  HomeScreen({required this.isStaff});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parking Spot Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parking Spot Details:',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            ParkingDetailItem(
              label: 'Name:',
              value: 'ABC Parking Lot',
            ),
            ParkingDetailItem(
              label: 'Location:',
              value: '123 Main Street, City, Country',
            ),
            ParkingDetailItem(
              label: 'Total Slots:',
              value: '100',
            ),
            if (isStaff) // Display available slots only for staff members
              ParkingDetailItem(
                label: 'Available Slots:',
                value: '70',
              ),
          ],
        ),
      ),
    );
  }
}

class ParkingDetailItem extends StatelessWidget {
  final String label;
  final String value;

  ParkingDetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 5.0),
          Expanded(
            child: Text('$value'),
          ),
        ],
      ),
    );
  }
}
