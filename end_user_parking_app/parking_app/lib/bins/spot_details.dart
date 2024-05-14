import 'package:flutter/material.dart';

class ParkingDetailsScreen extends StatefulWidget {
  const ParkingDetailsScreen({super.key});

  @override
  State<ParkingDetailsScreen> createState() => _ParkingDetailsScreenState();
}

class _ParkingDetailsScreenState extends State<ParkingDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Thrissur Town"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              width: screenSize.width,
              child: Container(
                width: screenSize.width,
                height: screenSize.height * 0.28, // Adjust the height as needed
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/parking.png',
                    width: screenSize.width, // Image width set to screen width
                    height: screenSize.height *
                        0.3, // Image height set to container height
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            // Generated code for this Row Widget...
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 306,
                  height: 81,
                  decoration: BoxDecoration(),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              Icons.star,
                              size: 16,
                              color: index < 3.4 ? Colors.amber : Colors.grey,
                            ),
                          ),
                        ),
                        Text(
                          'open/close',
                          style: TextStyle(
                            fontFamily: 'Readex Pro',
                            letterSpacing: 0,
                          ),
                        ),
                        Text(
                          'available',
                          style: TextStyle(
                            fontFamily: 'Readex Pro',
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.directions_rounded,
                    color: Color(0xff567DF4),
                    size: 50,
                  ),
                )
              ],
            ),

            Container(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 516,
                    height: 58,
                    decoration: BoxDecoration(),
                    child: Align(
                      alignment: AlignmentDirectional(0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(-1, 0),
                            child: Icon(
                              Icons.location_pin,
                              color: Colors.grey,
                              size: 34,
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: Text(
                              'Thekkinkadu maidan,swaraj round',
                              style: TextStyle(
                                fontFamily: 'Readex Pro',
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 516,
                    height: 58,
                    decoration: BoxDecoration(),
                    child: Align(
                      alignment: AlignmentDirectional(0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(-1, 0),
                            child: Icon(
                              Icons.access_time_outlined,
                              color: Colors.grey,
                              size: 34,
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: Text(
                              'open',
                              style: TextStyle(
                                fontFamily: 'Readex Pro',
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: Text(
                              'closes 10 pm',
                              style: TextStyle(
                                fontFamily: 'Readex Pro',
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 516,
                    height: 58,
                    decoration: BoxDecoration(),
                    child: Align(
                      alignment: AlignmentDirectional(0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(-1, 0),
                            child: Icon(
                              Icons.currency_rupee,
                              color: Colors.grey,
                              size: 34,
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: Text(
                              '20 per hour',
                              style: TextStyle(
                                fontFamily: 'Readex Pro',
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 516,
                    height: 58,
                    decoration: BoxDecoration(),
                    child: Align(
                      alignment: AlignmentDirectional(0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(-1, 0),
                            child: Icon(
                              Icons.local_parking,
                              color: Colors.grey,
                              size: 34,
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: Text(
                              'available',
                              style: TextStyle(
                                fontFamily: 'Readex Pro',
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            print('Button pressed ...');
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
                      ),
                      SizedBox(width: 30), // Add space between buttons
                      Container(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            print('Button pressed ...');
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
                            'directions',
                            style: TextStyle(
                              fontFamily: 'Readex Pro',
                              color: Colors.white,
                              fontSize: 16,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
