import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:security_app/screens/billingpage.dart';

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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    double horizontalPadding = width * 0.02; // 2% of the screen width
    double verticalPadding = height * 0.01; // 1% of the screen height

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
            // print('Parking Space ID: ${widget.spaceId}');
            // print('Address: ${parkingSpaceData['address']}');
            // print(
            //     'Availability (Four-Wheelers): ${parkingSpaceData['availability_four']}');
            // print(
            //     'Availability (Two-Wheelers): ${parkingSpaceData['availability_two']}');
            // print(
            //     'Capacity (Four-Wheelers): ${parkingSpaceData['capacity_four']}');
            // print(
            //     'Capacity (Two-Wheelers): ${parkingSpaceData['capacity_two']}');
            // print(
            //     'Parking Fee per Hour (Four-Wheelers): ${parkingSpaceData['fee_ph_four']}');
            // print(
            //     'Parking Fee per Hour (Two-Wheelers): ${parkingSpaceData['fee_ph_two']}');
            // print('Location: ${parkingSpaceData['location']}');
            // print('Rating: ${parkingSpaceData['rating']}');
            // print('Space Name: ${parkingSpaceData['space_name']}');
            // print('Working Time: ${parkingSpaceData['working_time']}');
            // // Add more details as needed
            List<Widget> boxesfour = [];

            for (int i = 0; i <= parkingSpaceData['capacity_four']; i++) {
              boxesfour.add(
                GestureDetector(
                  onTap: () {
                    if (confirmedBoxes.containsKey(i) && confirmedBoxes[i]!) {
                      // Show dialog to confirm exit
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirm Exit'),
                          content:
                              Text('Are you sure you want to exit this box?'),
                          actions: [
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.pop(
                                context,
                                // MaterialPageRoute(
                                //     builder: (context) => BillingPage()),
                              ),
                            ),
                            TextButton(
                              child: Text('Confirm Exit'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BillingPage(
                                      vehicleNumber: boxContents[i]!,
                                      entryTime: boxTimestamps[i]!,
                                      exitTime: Timestamp.now(),
                                      parkingSpaceData: parkingSpaceData,
                                      spaceId: widget.spaceId,
                                    ),
                                  ),
                                ).then((value) async {
                                  if (value != null && value) {
                                    // Reset the box status and update Firestore
                                    setState(() {
                                      confirmedBoxes[i] = false;
                                      boxContents[i] = '';
                                      //boxTimestamps[i] = null;
                                      //boxTimestamps[i] = null;
                                    });
                                    // Update the availability of four-wheelers
                                    // Update the availability of four-wheelers

                                    await _increAvailabilityFour();
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoxDetailsPage(
                            boxIndex: i,
                            capacity: parkingSpaceData['capacity_four'],
                            confirmedBoxes: confirmedBoxes,
                            updateBoxTimestamp: (index, timestamp) {
                              setState(() {
                                boxTimestamps[index] = timestamp;
                              });
                            },
                          ),
                        ),
                      ).then((value) async {
                        if (value != null) {
                          setState(() {
                            confirmedBoxes[i] = value['confirmed'];
                            boxContents[i] = value['content'];
                          });
                          await _decrementAvailabilityFour();
                        }
                      });
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding,
                        verticalPadding, horizontalPadding, 0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: confirmedBoxes.containsKey(i) &&
                                confirmedBoxes[i]!
                            ? Colors.grey // default color when confirmed
                            : confirmedBoxes.containsKey(i) &&
                                    !confirmedBoxes[i]!
                                ? Colors
                                    .white // change to white when exit confirmed
                                : Colors
                                    .white, // default color when not confirmed

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
                        padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            verticalPadding,
                            horizontalPadding,
                            verticalPadding),
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
                                    width: width * 0.95,
                                    height: height * 0.1,
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
                                          confirmedBoxes.containsKey(i) &&
                                                  confirmedBoxes[i]! &&
                                                  boxTimestamps.containsKey(i)
                                              ? Text(
                                                  'Entry time:  ${DateFormat.jm().format(boxTimestamps[i]!.toDate())}')
                                              : Text(''),
                                          SizedBox(height: height * 0.01),
                                          // boxTimestamps.containsKey(i) &&
                                          //         boxTimestamps[i] != null
                                          confirmedBoxes.containsKey(i) &&
                                                  confirmedBoxes[i]! &&
                                                  boxTimestamps.containsKey(i)
                                              ? Text(DateFormat.yMMMd().format(
                                                  boxTimestamps[i]!.toDate()))
                                              : Text(''),
                                          // style: TextStyle(fontSize: 12),
                                          // ),
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
                          updateBoxTimestamp: (index, timestamp) {
                            setState(() {
                              boxTimestampsTwo[index] = timestamp;
                            });
                          },
                        ),
                      ),
                    ).then((value) async {
                      if (value != null) {
                        setState(() {
                          confirmedBoxesTwo[i] = value['confirmed'];
                          boxContentsTwo[i] = value['content'];
                        });

                        int newavailtwo =
                            parkingSpaceData['availability_two'] - 1;
                        parkingSpaceData['availability_two'] = newavailtwo;

                        try {
                          QuerySnapshot querySnapshot = await FirebaseFirestore
                              .instance
                              .collection('PARKING SPACES')
                              .where('space_id',
                                  isEqualTo: int.parse(widget.spaceId))
                              .get();

                          if (querySnapshot.docs.isNotEmpty) {
                            DocumentReference docRef =
                                querySnapshot.docs.first.reference;
                            await docRef.update({
                              'availability_two': newavailtwo,
                            });
                            print('Updated availability_two to $newavailtwo');
                          } else {
                            print('Document does not exist');
                          }
                        } catch (e) {
                          print('Error updating Firestore: $e');
                        }
                      }
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(horizontalPadding,
                        verticalPadding, horizontalPadding, 0),
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
                        padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            verticalPadding,
                            horizontalPadding,
                            verticalPadding),
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
                                    width: width * 0.95,
                                    height: height * 0.1,
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

  Future<void> _increAvailabilityFour() async {
    final db = FirebaseFirestore.instance;
    final QuerySnapshot<Map<String, dynamic>> spaceRef = await db
        .collection('PARKING SPACES')
        .where('space_id', isEqualTo: int.parse(widget.spaceId))
        .get();

    if (spaceRef.docs.isNotEmpty) {
      final batch = db.batch();
      final DocumentReference<Map<String, dynamic>> spaceRefDoc =
          spaceRef.docs.first.reference;
      print('Referencing document: ${spaceRefDoc.path}');

      final DocumentSnapshot<Map<String, dynamic>> spaceDoc =
          await spaceRefDoc.get();

      if (spaceDoc.exists) {
        int currentAvailability = spaceDoc.get('availability_four');
        int newAvailability = currentAvailability + 1; // increment by 1

        batch.update(spaceRefDoc, {'availability_four': newAvailability});
        print('Updated availability_four to $newAvailability');
      } else {
        print('Document does not exist');
      }

      try {
        await batch.commit();
      } catch (e) {
        print('Error committing batch write: $e');
      }
    } else {
      print('No documents found');
    }
  }

  Future<void> _decrementAvailabilityFour() async {
    final db = FirebaseFirestore.instance;
    final QuerySnapshot<Map<String, dynamic>> spaceRef = await db
        .collection('PARKING SPACES')
        .where('space_id', isEqualTo: int.parse(widget.spaceId))
        .get();

    if (spaceRef.docs.isNotEmpty) {
      final batch = db.batch();
      final DocumentReference<Map<String, dynamic>> spaceRefDoc =
          spaceRef.docs.first.reference;
      print('Referencing document: ${spaceRefDoc.path}');

      final DocumentSnapshot<Map<String, dynamic>> spaceDoc =
          await spaceRefDoc.get();

      if (spaceDoc.exists) {
        int currentAvailability = spaceDoc.get('availability_four');
        int newAvailability = currentAvailability - 1; // decrement by 1

        batch.update(spaceRefDoc, {'availability_four': newAvailability});
        print('Updated availability_four to $newAvailability');
      } else {
        print('Document does not exist');
      }

      try {
        await batch.commit();
      } catch (e) {
        print('Error committing batch write: $e');
      }
    } else {
      print('No documents found');
    }
  }

  Future<void> _updateAvailabilityFour(int newAvailability) async {
    final db = FirebaseFirestore.instance;
    final QuerySnapshot<Map<String, dynamic>> spaceRef = await db
        .collection('PARKING SPACES')
        .where('space_id', isEqualTo: int.parse(widget.spaceId))
        .get();

    if (spaceRef.docs.isNotEmpty) {
      final batch = db.batch();
      final DocumentReference<Map<String, dynamic>> spaceRefDoc =
          spaceRef.docs.first.reference;
      print('Referencing document: ${spaceRefDoc.path}');

      final DocumentSnapshot<Map<String, dynamic>> spaceDoc =
          await spaceRefDoc.get();

      if (spaceDoc.exists) {
        final currentAvailability = spaceDoc.get('availability_four');
        batch.update(spaceRefDoc, {'availability_four': newAvailability});
        print('Updated availability_four to $newAvailability');
      } else {
        print('Document does not exist');
      }

      try {
        await batch.commit();
      } catch (e) {
        print('Error committing batch write: $e');
      }
    } else {
      print('No documents found');
    }
  }

  Future<void> _updateAvailabilityTwo(int newAvailability) async {
    final db = FirebaseFirestore.instance;
    final spaceRef = db.collection('PARKING SPACES').doc(widget.spaceId);

    await db.runTransaction((transaction) async {
      final spaceDoc = await transaction.get(spaceRef);
      if (spaceDoc.exists) {
        final currentAvailability = spaceDoc.get('availability_two');
        transaction.update(spaceRef, {'availability_two': newAvailability});
        print('Updated availability_two to $newAvailability');
      } else {
        print('Document does not exist');
      }
    }).catchError((e) => print('Error updating Firestore: $e'));
  }
}

class BoxDetailsPage extends StatefulWidget {
  final int boxIndex;
  final int capacity;
  final Map<int, bool> confirmedBoxes;
  final Function(int, Timestamp) updateBoxTimestamp;

  BoxDetailsPage({
    required this.boxIndex,
    required this.capacity,
    required this.confirmedBoxes,
    required this.updateBoxTimestamp,
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
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      widget.confirmedBoxes[widget.boxIndex] = true;
                    });
                    final vehicleData = {
                      'vehicle_number': _contentController.text,
                      'entry_time': Timestamp.now(),
                    };
                    await FirebaseFirestore.instance
                        .collection('VEHICLES')
                        .add(vehicleData);
                    widget.updateBoxTimestamp(widget.boxIndex, Timestamp.now());
                    Navigator.pop(context, {
                      'confirmed': true,
                      'content': _contentController.text,
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

class ConfirmationPage extends StatefulWidget {
  final String vehicleNumber;
  final Timestamp entryTime;
  final Timestamp exitTime;

  var parkingSpaceData;

  var spaceId;

  ConfirmationPage({
    required this.vehicleNumber,
    required this.entryTime,
    required this.exitTime,
    required this.parkingSpaceData,
    required this.spaceId,
  });

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Exit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Number:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              widget.vehicleNumber,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Entry Time:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat.yMMMd().add_jm().format(widget.entryTime.toDate()),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Exit Time:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat.yMMMd().add_jm().format(widget.exitTime.toDate()),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // onPressed:
                  // () async {
                  //   int newavailfour =
                  //       widget.parkingSpaceData['availability_four'] + 1;
                  //   widget.parkingSpaceData['availability_four'] = newavailfour;

                  //   print("increased!!!!!!");

                  //   try {
                  //     QuerySnapshot querySnapshot = await FirebaseFirestore
                  //         .instance
                  //         .collection('PARKING SPACES')
                  //         .where('space_id',
                  //             isEqualTo: int.parse(widget.spaceId))
                  //         .get();

                  //     if (querySnapshot.docs.isNotEmpty) {
                  //       DocumentReference docRef =
                  //           querySnapshot.docs.first.reference;
                  //       await docRef.update({
                  //         'availability_four': newavailfour,
                  //       });
                  //       print(
                  //           'Updated availability_four  iiii  to $newavailfour');
                  //     } else {
                  //       print('Document does not exist');
                  //     }
                  //   } catch (e) {
                  //     print('Error updating Firestore: $e');
                  //   }

                  //   Navigator.pop(context, true);
                  //   Navigator.pop(context, true);
                  // };

                  Navigator.pop(context, true);
                  Navigator.pop(context, true);
                },
                child: Text('Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}