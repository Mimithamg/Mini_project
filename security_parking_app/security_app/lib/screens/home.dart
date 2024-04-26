import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SecurityhomeWidget extends StatefulWidget {
  final String spaceId;
  const SecurityhomeWidget({Key? key, required this.spaceId}) : super(key: key);

  @override
  State<SecurityhomeWidget> createState() => _SecurityhomeWidgetState();
}

class _SecurityhomeWidgetState extends State<SecurityhomeWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Map<int, bool> confirmedBoxes = {};
  Map<int, String> boxContents = {};
  Map<int, Timestamp> boxTimestamps = {};
  Map<int, bool> confirmedBoxesTwo = {};
  Map<int, String> boxContentsTwo = {};
  Map<int, Timestamp> boxTimestampsTwo = {};

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tabController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    );

    return Scaffold(
      //backgroundColor: Color(0xFF4B39EF),
      //backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color(0xFF4B39EF),
        automaticallyImplyLeading: false,
        title: Text(
          'Home',
          style: TextStyle(
            fontFamily: 'Outfit',
            color: Colors.white,
            fontSize: 22,
            letterSpacing: 0,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search_sharp,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              print('IconButton pressed ...');
            },
          ),
        ],
        centerTitle: false,
        elevation: 0,
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: _fetchParkingSpace(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text('No data found for ID: ${widget.spaceId}'));
          } else {
            var parkingSpaceData = snapshot.data!.docs.first.data();
            // Print parking space details in terminal
            print('Parking Space ID: ${widget.spaceId}');
            print('Address: ${parkingSpaceData['address']}');
            print(
                'Availability (Four-Wheelers): ${parkingSpaceData['availability_four']}');
            print(
                'Availability (Two-Wheelers): ${parkingSpaceData['availability_two']}');
            print(
                'Capacity (Four-Wheelers): ${parkingSpaceData['capacity_four']}');
            print(
                'Capacity (Two-Wheelers): ${parkingSpaceData['capacity_two']}');
            print(
                'Parking Fee per Hour (Four-Wheelers): ${parkingSpaceData['fee_ph_four']}');
            print(
                'Parking Fee per Hour (Two-Wheelers): ${parkingSpaceData['fee_ph_two']}');
            print('Location: ${parkingSpaceData['location']}');
            print('Rating: ${parkingSpaceData['rating']}');
            print('Space Name: ${parkingSpaceData['space_name']}');
            print('Working Time: ${parkingSpaceData['working_time']}');
            // Add more details as needed
            List<Widget> boxesfour = [];

            for (int i = 0; i <= parkingSpaceData['capacity_four']; i++) {
              boxesfour.add(
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BoxDetailsPage(
                          boxIndex: i,
                          capacity: parkingSpaceData['capacity_four'],
                          confirmedBoxes: confirmedBoxes,
                        ),
                      ),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          confirmedBoxes[i] = value['confirmed'];
                          boxContents[i] = value['content'];
                          if (value['timestamp'] != null) {
                            boxTimestamps[i] = value['timestamp'];
                          }
                        });
                      }
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: confirmedBoxes.containsKey(i)
                            ? Colors.grey
                            : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 3,
                            color: Color(0x20000000),
                            offset: Offset(
                              0.0,
                              1,
                            ),
                          )
                        ],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8, 8, 12, 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 375,
                                    height: 70,
                                    color: Colors
                                        .white, // Replace with your desired color
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          boxContents.containsKey(i)
                                              ? Text(boxContents[i]!)
                                              : Text(''),
                                          SizedBox(height: 4),
                                          Text(
                                            boxTimestamps.containsKey(i) &&
                                                    boxTimestamps[i] != null
                                                ? 'Entry time:  ${DateFormat.jm().format(boxTimestamps[i]!.toDate())}'
                                                : '',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            boxTimestamps.containsKey(i) &&
                                                    boxTimestamps[i] != null
                                                ? DateFormat.yMMMd().format(
                                                    boxTimestamps[i]!.toDate())
                                                : '',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

// Print details of each box in the boxesfour list
            // for (int i = 0; i <= parkingSpaceData['capacity_four']; i++) {
            //   print('Box ${i + 1} Details:');
            //   print('  Confirmed: ${confirmedBoxes[i]}');
            //   print('  Content: ${boxContents[i]}');
            //   print(
            //       '  Timestamp: ${DateFormat.yMMMd().add_jm().format(boxTimestamps[i]!.toDate())}');
            // }
            List<Widget> boxestwo = [];

            for (int i = 0; i <= parkingSpaceData['capacity_two']; i++) {
              boxestwo.add(
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BoxDetailsPage(
                          boxIndex: i,
                          capacity: parkingSpaceData['capacity_two'],
                          confirmedBoxes: confirmedBoxesTwo,
                        ),
                      ),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          confirmedBoxesTwo[i] = value['confirmed'];
                          boxContentsTwo[i] = value['content'];
                          if (value['timestamp'] != null) {
                            boxTimestampsTwo[i] = value['timestamp'];
                          }
                        });
                      }
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: confirmedBoxesTwo.containsKey(i)
                            ? Colors.grey
                            : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 3,
                            color: Color(0x20000000),
                            offset: Offset(
                              0.0,
                              1,
                            ),
                          )
                        ],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8, 8, 12, 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 375,
                                    height: 70,
                                    color: Colors
                                        .white, // Replace with your desired color
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          boxContentsTwo.containsKey(i)
                                              ? Text(boxContentsTwo[i]!)
                                              : Text(''),
                                          SizedBox(height: 4),
                                          Text(
                                            boxTimestampsTwo.containsKey(i) &&
                                                    boxTimestampsTwo[i] != null
                                                ? 'Entry time:  ${DateFormat.jm().format(boxTimestampsTwo[i]!.toDate())}'
                                                : '',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            boxTimestampsTwo.containsKey(i) &&
                                                    boxTimestampsTwo[i] != null
                                                ? DateFormat.yMMMd().format(
                                                    boxTimestampsTwo[i]!
                                                        .toDate())
                                                : '',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            return SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment(0, 0),
                            child: TabBar(
                              labelColor: Colors.blue,
                              unselectedLabelColor:
                                  Color.fromARGB(179, 7, 0, 0),
                              labelStyle: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                color: const Color.fromARGB(255, 240, 82, 82),
                                fontSize: 18,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                              ),
                              //unselectedLabelStyle: TextStyle(),
                              //indicatorColor: Color(0xFF4B39EF),
                              //indicatorWeight: 3,
                              tabs: [
                                Tab(
                                  text: 'Four wheeler',
                                ),
                                Tab(
                                  text: 'Two wheeler',
                                ),
                              ],
                              controller: _tabController,
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                Container(
                                  color: Color(0xFFF1F4F8),
                                  child: ListView(
                                    padding: EdgeInsets.zero,
                                    scrollDirection: Axis.vertical,
                                    children: boxesfour,
                                  ),
                                ),
                                Container(
                                  color: Color(0xFFF1F4F8),
                                  child: ListView(
                                    padding: EdgeInsets.zero,
                                    scrollDirection: Axis.vertical,
                                    children: boxestwo,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
        .where('space_id', isEqualTo: int.parse(widget.spaceId))
        .get();
  }
}

class YourNextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Page'),
      ),
      body: Center(
        child: Text('This is the next page!'),
      ),
    );
  }
}

class BoxDetailsPage extends StatefulWidget {
  final int boxIndex;
  final int capacity;
  final Map<int, bool> confirmedBoxes;

  BoxDetailsPage({
    required this.boxIndex,
    required this.capacity,
    required this.confirmedBoxes,
  });

  @override
  _BoxDetailsPageState createState() => _BoxDetailsPageState();
}

class _BoxDetailsPageState extends State<BoxDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle entry details'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Enter vehicle number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      widget.confirmedBoxes[widget.boxIndex] = true;
                    });
                    Navigator.pop(context, {
                      'confirmed': true,
                      'content': _contentController.text,
                      'timestamp': Timestamp.now(),
                    });
                  }
                },
                child: Text('Confirm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
