import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:url_launcher/url_launcher.dart';



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
        title: Text('Reservation Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 212, 230, 255),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                child: Column(
                  children: [
                    _buildQRCodeSection(),
                    SizedBox(height: 16),
                    _buildReservationDetails(),
                    SizedBox(height: 16),
                    _buildWarningText(),
                  ],
                ),
              ),
              SizedBox(height: 16),
              _buildGetDirectionButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRCodeSection() {
    // Generate QR code data
    String qrData = '$vehicleNumber\n$bookingTime\n$vehicleType\n$parkingSpaceName';

    return Column(
      children: [
        const Text(
          'Kindly present this QR code on the security phone upon your arrival at the parking area.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        // Display QR code with generated data
        SizedBox(
          width: 150, // Adjust width as needed
          height: 150, // Adjust height as needed
          child: PrettyQrView.data(data: qrData),
        ),
      ],
    );
  }

  Widget _buildReservationDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        const Text(
          'Your reservation is successful.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        SizedBox(height: 8),
        _buildDetailRow('Vehicle Number', vehicleNumber),
        _buildDetailRow('Booking Time', bookingTime),
        _buildDetailRow('Vehicle Type', vehicleType),
        _buildDetailRow('Parking Space Name', parkingSpaceName),
      ],
    );
  }

  Widget _buildDetailRow(String title, String value) {
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
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningText() {
    return Text(
      'Warning: Delay of more than 30 minutes may lead to cancellation of reservation.',
      style: TextStyle(
        color: Colors.red,
      ),
    );
  }

  Widget _buildGetDirectionButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Navigate to Google Maps for directions
        String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=${parkingSpaceName}';
        if (await canLaunch(googleMapsUrl)) {
          await launch(googleMapsUrl);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open Google Maps.'),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xff567DF4),
        padding: EdgeInsets.symmetric(vertical: 7, horizontal: 140),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      child: const Text(
        'Get Direction',
        style: TextStyle(
          fontFamily: 'Readex Pro',
          color: Colors.white,
          fontSize: 17,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
