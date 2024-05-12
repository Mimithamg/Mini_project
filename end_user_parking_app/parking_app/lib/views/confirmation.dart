import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;

class DetailsReservation extends StatefulWidget {
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
  _DetailsReservationState createState() => _DetailsReservationState();
}

class _DetailsReservationState extends State<DetailsReservation> {
  late Future<void> _qrCodeGenerationFuture;

  @override
  void initState() {
    super.initState();
    _qrCodeGenerationFuture = _generateQRCode();
  }

  Future<void> _generateQRCode() async {
    // Get the current directory where the script is running
    String currentDirectory = Directory.current.path;

    // Convert the relative path to an absolute path
    String generatedFilesDirectory = path.join(currentDirectory, 'generated_files');
    String qrCodeFilePath = path.join(generatedFilesDirectory, 'qr_code.png');

    // Execute Python script
    await Process.run('python', [
      'python_scripts/generate_qr_code.py',
      widget.vehicleNumber,
      widget.bookingTime,
      widget.vehicleType,
      widget.parkingSpaceName,
      qrCodeFilePath, // Use the absolute path
    ]).then((ProcessResult result) {
      print(result.stdout);
      print(result.stderr);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
          
            Expanded(
              child: Text('Reservation Details'),
            ),
          ],
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
                    const Text(
                      'Kindly present this QR code on the security phone upon your arrival at the parking area.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 16),
                    FutureBuilder<void>(
                      future: _qrCodeGenerationFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Image.file(File(path.join(Directory.current.path, 'generated_files', 'qr_code.png')));
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    ),
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
        _buildDetailRow('Vehicle Number', widget.vehicleNumber),
        _buildDetailRow('Booking Time', widget.bookingTime),
        _buildDetailRow('Vehicle Type', widget.vehicleType),
        _buildDetailRow('Parking Space Name', widget.parkingSpaceName),
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
        String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=${widget.parkingSpaceName}';
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
        padding: EdgeInsets.symmetric(vertical: 7,horizontal: 140),
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