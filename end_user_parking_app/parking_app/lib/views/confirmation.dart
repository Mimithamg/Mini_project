import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailsReservation extends StatelessWidget {
  final String vehicleNumber;
  final String bookingTime;
  final String vehicleType;

  final String parkingSpaceName;

  const DetailsReservation({
    Key? key,
    required this.vehicleNumber,
    required this.bookingTime,
    required this.vehicleType,
    required this.parkingSpaceName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reservation Details',
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReservationDetails(
                vehicleNumber: vehicleNumber,
                bookingTime: bookingTime,
                vehicleType: vehicleType,
                parkingSpaceName: parkingSpaceName,
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _parseBookingTime(String bookingTime) {
    // Assuming bookingTime is in the format "YYYY-MM-DD HH:MM:SS"
    List<String> parts = bookingTime.split(' ');
    String datePart = parts[0];
    String timePart = parts[1];

    // Splitting date part into year, month, and day
    List<String> dateParts = datePart.split('-');
    int year = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int day = int.parse(dateParts[2]);

    // Splitting time part into hour and minute
    List<String> timeParts = timePart.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    return DateTime(year, month, day, hour, minute);
  }
}

class ReservationDetails extends StatelessWidget {
  final String vehicleNumber;
  final String bookingTime;
  final String vehicleType;

  final String parkingSpaceName;

  const ReservationDetails({
    Key? key,
    required this.vehicleNumber,
    required this.bookingTime,
    required this.vehicleType,
    required this.parkingSpaceName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // String formattedBookingTime =
    //     DateFormat('MMMM d \'at\' h:mm a').format(bookingTime);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Icon(
              Icons.check_rounded,
              color: Colors.green,
              size: 64,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Reservation Success',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const Divider(height: 20, thickness: 2),
          _buildRow('Vehicle Number', vehicleNumber),
          _buildRow('Booking Time', bookingTime),
          _buildRow('Vehicle Type', vehicleType),
          //_buildRow('Fee per hour', feePerHour),
          _buildRow('Parking Space Name', parkingSpaceName),
          const SizedBox(height: 16),
          Text(
            'Your reservation is successful with the above details.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Warning: Delay of more than 30 minutes may lead to cancellation of reservation.',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
