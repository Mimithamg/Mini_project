import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parking_app/views/spot_details.dart';

class ParkingArea {
  final String name;
  final double rating;
  final String workingTime;
  final int availabilityTwoWheelers;
  final int availabilityFourWheelers;
  final double feePerHourTwoWheelers;
  final double feePerHourFourWheelers;
  final String address;

  ParkingArea({
    required this.name,
    required this.rating,
    required this.workingTime,
    required this.availabilityTwoWheelers,
    required this.availabilityFourWheelers,
    required this.feePerHourTwoWheelers,
    required this.feePerHourFourWheelers,
    required this.address,
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
        address: doc['address'],
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
        builder: (context) => ParkingDetailsScreen(area: area),
      ),
    );
  }

  void filterSearchResults(String query) {
    List<ParkingArea> searchResults = [];
    searchResults.addAll(allAreas); // Use original list for filtering
    if (query.isNotEmpty) {
      List<ParkingArea> dummySearchList = [];
      searchResults.forEach((item) {
        if (item.address.toLowerCase().contains(query.toLowerCase())) {
          // Check address instead of name
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

class ParkingDetailsScreen extends StatefulWidget {
  final ParkingArea area;
  const ParkingDetailsScreen({super.key, required this.area});

  @override
  State<ParkingDetailsScreen> createState() => _ParkingDetailsScreenState();
}

class _ParkingDetailsScreenState extends State<ParkingDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    TimeOfDay _parseTimeString(String timeString) {
      bool isPM = timeString.toLowerCase().contains('pm');
      List<String> parts =
          timeString.replaceAll(RegExp(r'[^0-9]'), '').split('');
      int hour = int.parse(parts[0]);
      if (isPM && hour != 12) {
        hour += 12;
      } else if (!isPM && hour == 12) {
        hour = 0;
      }
      int minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      return TimeOfDay(hour: hour, minute: minute);
    }

    // Parse the workingTime string into TimeOfDay objects
    List<String> workingHours = widget.area.workingTime.split(' to ');
    String openingTimeString = workingHours[0].trim(); // "9 am"
    String closingTimeString = workingHours[1].trim(); // "7 pm"

    // Parse opening time
    TimeOfDay openingTime = _parseTimeString(openingTimeString);

    // Parse closing time
    TimeOfDay closingTime = _parseTimeString(closingTimeString);

    // Get the current time
    DateTime now = DateTime.now();
    TimeOfDay currentTime = TimeOfDay.fromDateTime(now);

    // Check if the current time is within the working hours
    bool isOpen = currentTime.hour > openingTime.hour &&
        currentTime.hour < closingTime.hour;

    // Build the text accordingly
    String openCloseText = isOpen
        ? 'Open until ${closingTime.format(context)}'
        : 'Closed. Opens at ${openingTime.format(context)}';

    // Function to parse time string to TimeOfDay

    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.area.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                width: screenSize.width,
                child: Container(
                  width: screenSize.width,
                  height:
                      screenSize.height * 0.28, // Adjust the height as needed
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/parking.png',
                      width:
                          screenSize.width, // Image width set to screen width
                      height: screenSize.height *
                          0.3, // Image height set to container height
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
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
                                color: index < widget.area.rating
                                    ? Colors.amber
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          Text(
                            openCloseText,
                            style: TextStyle(
                              fontFamily: 'Readex Pro',
                              letterSpacing: 0,
                            ),
                          ),
                          Text(
                            '${widget.area.availabilityFourWheelers > 1 ? "Available for four-wheelers" : "Available only one slot left"}',
                            style: TextStyle(
                              fontFamily: 'Readex Pro',
                              letterSpacing: 0,
                            ),
                          ),
                          Text(
                            '${widget.area.availabilityTwoWheelers > 1 ? "Available for two wheelers" : "Available only one slot left"}',
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
                                '${widget.area.address ?? "Address not available"}',
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
                                openCloseText,
                                style: TextStyle(
                                  fontFamily: 'Readex Pro',
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            // Align(
                            //   alignment: AlignmentDirectional(0, 0),
                            //   child: Text(
                            //     'closes 10 pm',
                            //     style: TextStyle(
                            //       fontFamily: 'Readex Pro',
                            //       letterSpacing: 0,
                            //     ),
                            //   ),
                            // ),
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
                            Column(
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Text(
                                    'for four Wheelers: \$${widget.area.feePerHourFourWheelers} ,',
                                    style: TextStyle(
                                      fontFamily: 'Readex Pro',
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Text(
                                    'for Two Wheelers: \$${widget.area.feePerHourTwoWheelers}',
                                    style: TextStyle(
                                      fontFamily: 'Readex Pro',
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                              ],
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
                            Column(
                              children: [
                                Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Text(
                                    '${widget.area.availabilityFourWheelers > 1 ? "Available for four-wheelers" : "Available only one slot left"}',
                                    style: TextStyle(
                                      fontFamily: 'Readex Pro',
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Text(
                                    '${widget.area.availabilityTwoWheelers > 1 ? "Available for two-wheelers" : "Available only one slot left"}',
                                    style: TextStyle(
                                      fontFamily: 'Readex Pro',
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                              ],
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
      ),
    );
  }
}
