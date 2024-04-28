import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillingPage extends StatefulWidget {
  const BillingPage(
      {Key? key,
      required this.vehicleNumber,
      required this.entryTime,
      required this.exitTime,
      required this.parkingSpaceData,
      required this.spaceId})
      : super(key: key);

  final String vehicleNumber;
  final Timestamp entryTime;
  final Timestamp exitTime;
  final Map<String, dynamic> parkingSpaceData;
  final String spaceId;

  @override
  _BillingPageState createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  @override
  Widget build(BuildContext context) {
    Duration timeDifference =
        widget.exitTime!.toDate().difference(widget.entryTime!.toDate());

    int hours = timeDifference.inHours;
    int minutes = timeDifference.inMinutes.remainder(60);

    print(widget.parkingSpaceData);
    int fee = widget.parkingSpaceData['fee_ph_four'];
    int newhr = 1;
    int totalAmount;
    if (hours < 1) {
      totalAmount = newhr * fee;
    } else {
      totalAmount = hours * fee;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.vehicleNumber,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: Color(0xFF15161E),
                  fontSize: 22,
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Below are the details of billing',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color(0xFF606A85),
                  fontSize: 14,
                  letterSpacing: 0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              Align(
                alignment: AlignmentDirectional(0, -1),
                child: Padding(
                  padding: EdgeInsets.all(6),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxWidth: 1170,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Details',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          buildDetailRow(
                              'Vehicle Number', widget.vehicleNumber),
                          buildDetailRow('Entry Time',
                              ' ${DateFormat.jm().format(widget.entryTime!.toDate())}'),
                          buildDetailRow('Exit Time',
                              ' ${DateFormat.jm().format(widget.exitTime!.toDate())}'),
                          buildDetailRow(
                              'Time Duration', '$hours hours $minutes minutes'),
                          buildDetailRow('Fee per Hour', fee.toString()),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$totalAmount',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.grey),
              const SizedBox(height: 16),
              Center(
                  child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                          Navigator.pop(context, true);
                        },
                        child: Text('cancel'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Color(0xFF15161E),
                          backgroundColor: Colors.white,
                          elevation: 0,
                          side: BorderSide(
                            color: Color(0xFFE5E7EB),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                          Navigator.pop(context, true);
                        },
                        child: Text('confirm bill'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color(0xFF6F61EF),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}