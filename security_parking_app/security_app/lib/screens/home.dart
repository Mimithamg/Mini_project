import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:security_app/screens/billingpage.dart';
import 'package:security_app/screens/numberplate.dart';

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
  Map<int, String> imageUrlFour = {};
  Map<int, String> imageUrlTwo = {};
  int max_capacity_four = 0;
  int max_capacity_two = 0;
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
              showSearchDialog(context);
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
            max_capacity_four = parkingSpaceData['capacity_four'];
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
                                    });

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
                            imageUrl: imageUrlFour,
                            spaceId: widget.spaceId,
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
                  child: SizedBox(
                    width: double.infinity,
                    height: height * 0.13,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.02,
                        vertical: MediaQuery.of(context).size.width * 0.01,
                      ),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: width * 0.95,
                                      height: height * 0.1,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors
                                            .white, // Replace with your desired color
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              width: width * 0.2,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Slot ${i + 1}'),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    confirmedBoxes.containsKey(
                                                                i) &&
                                                            confirmedBoxes[i]!
                                                        ? 'Filled'
                                                        : 'Vacant',
                                                    style: TextStyle(
                                                      color: confirmedBoxes
                                                                  .containsKey(
                                                                      i) &&
                                                              confirmedBoxes[i]!
                                                          ? Colors.red
                                                          : Colors.green,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Container(
                                            width: width * 0.4,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                boxContents.containsKey(i)
                                                    ? Text(
                                                        boxContents[i]!,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 24),
                                                      )
                                                    : Text(''),
                                                SizedBox(height: 4),
                                                confirmedBoxes.containsKey(i) &&
                                                        confirmedBoxes[i]! &&
                                                        boxTimestamps
                                                            .containsKey(i)
                                                    ? Text(
                                                        'Entry time: ${DateFormat.jm().format(boxTimestamps[i]!.toDate())}',
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      )
                                                    : Text(''),
                                                SizedBox(
                                                    height: height * 0.005),
                                                confirmedBoxes.containsKey(i) &&
                                                        confirmedBoxes[i]! &&
                                                        boxTimestamps
                                                            .containsKey(i)
                                                    ? Text(
                                                        DateFormat.yMMMd()
                                                            .format(
                                                                boxTimestamps[
                                                                        i]!
                                                                    .toDate()),
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      )
                                                    : Text(''),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Container(
                                            child:
                                                confirmedBoxes.containsKey(i) &&
                                                        confirmedBoxes[i]! &&
                                                        imageUrlFour[i] != null
                                                    ? Image.network(
                                                        imageUrlFour[i]!)
                                                    : null,
                                          )
                                        ],
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
                ),
              );
            }
            max_capacity_two = parkingSpaceData['capacity_two'];
            List<Widget> boxesTwo = [];

            for (int i = 0; i <= parkingSpaceData['capacity_two']; i++) {
              boxesTwo.add(
                GestureDetector(
                  onTap: () {
                    if (confirmedBoxesTwo.containsKey(i) &&
                        confirmedBoxesTwo[i]!) {
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
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              NumberPlateReader()));
                                }
                                //=> Navigator.pop(
                                //   context,
                                // ),

                                ),
                            TextButton(
                              child: Text('Confirm Exit'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BillingPage(
                                      vehicleNumber: boxContentsTwo[i]!,
                                      entryTime: boxTimestampsTwo[i]!,
                                      exitTime: Timestamp.now(),
                                      parkingSpaceData: parkingSpaceData,
                                      spaceId: widget.spaceId,
                                    ),
                                  ),
                                ).then((value) async {
                                  if (value != null && value) {
                                    // Reset the box status and update Firestore
                                    setState(() {
                                      confirmedBoxesTwo[i] = false;
                                      boxContentsTwo[i] = '';
                                    });
                                    await _increAvailabilityTwo();
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
                            imageUrl: imageUrlTwo,
                            spaceId: widget.spaceId,
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
                          await _decrementAvailabilityTwo();
                        }
                      });
                    }
                  },
                  child: SizedBox(
                    width: double.infinity, // Adjust width as needed
                    height: height * 0.13,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.02,
                        vertical: MediaQuery.of(context).size.width * 0.01,
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: confirmedBoxesTwo.containsKey(i) &&
                                  confirmedBoxesTwo[i]!
                              ? Colors.grey // default color when confirmed
                              : confirmedBoxesTwo.containsKey(i) &&
                                      !confirmedBoxesTwo[i]!
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: width * 0.95,
                                      height: height * 0.1,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors
                                            .white, // Replace with your desired color
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              width: width * 0.2,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text('Slot ${i + 1}'),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    confirmedBoxesTwo
                                                                .containsKey(
                                                                    i) &&
                                                            confirmedBoxesTwo[
                                                                i]!
                                                        ? 'Filled'
                                                        : 'Vacant',
                                                    style: TextStyle(
                                                      color: confirmedBoxesTwo
                                                                  .containsKey(
                                                                      i) &&
                                                              confirmedBoxesTwo[
                                                                  i]!
                                                          ? Colors.red
                                                          : Colors.green,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Container(
                                            width: width * 0.4,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                boxContentsTwo.containsKey(i)
                                                    ? Text(
                                                        boxContentsTwo[i]!,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 24),
                                                      )
                                                    : Text(''),
                                                SizedBox(height: 4),
                                                confirmedBoxesTwo
                                                            .containsKey(i) &&
                                                        confirmedBoxesTwo[i]! &&
                                                        boxTimestampsTwo
                                                            .containsKey(i)
                                                    ? Text(
                                                        'Entry time: ${DateFormat.jm().format(boxTimestampsTwo[i]!.toDate())}',
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      )
                                                    : Text(''),
                                                SizedBox(
                                                    height: height * 0.005),
                                                confirmedBoxesTwo
                                                            .containsKey(i) &&
                                                        confirmedBoxesTwo[i]! &&
                                                        boxTimestampsTwo
                                                            .containsKey(i)
                                                    ? Text(
                                                        DateFormat.yMMMd()
                                                            .format(
                                                                boxTimestampsTwo[
                                                                        i]!
                                                                    .toDate()),
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      )
                                                    : Text(''),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Container(
                                            child: confirmedBoxesTwo
                                                        .containsKey(i) &&
                                                    confirmedBoxesTwo[i]! &&
                                                    imageUrlTwo[i] != null
                                                ? Image.network(imageUrlTwo[i]!)
                                                : null,
                                          )
                                        ],
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
                                    children: boxesTwo,
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

  Future<void> _increAvailabilityTwo() async {
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
        int currentAvailability = spaceDoc.get('availability_two');
        int newAvailability = currentAvailability + 1; // increment by 1

        batch.update(spaceRefDoc, {'availability_two': newAvailability});
        print('Updated availability_two to $newAvailability');
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

  Future<void> _decrementAvailabilityTwo() async {
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
        int currentAvailability = spaceDoc.get('availability_two');
        int newAvailability = currentAvailability - 1; // decrement by 1

        batch.update(spaceRefDoc, {'availability_two': newAvailability});
        print('Updated availability_two to $newAvailability');
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

  void showSearchDialog(BuildContext context) {
    String searchText = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search vehicle'),
        content: TextField(
          decoration: InputDecoration(hintText: 'Enter vehicle number'),
          onChanged: (value) {
            searchText = value;
          },
        ),
        actions: [
          TextButton(
            child: Text('Search'),
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              // Perform the search
              List<int> searchResults = [];
              for (int i = 0; i < max_capacity_four; i++) {
                if (boxContents[i] != null &&
                    boxContents[i]!
                        .toLowerCase()
                        .contains(searchText.toLowerCase())) {
                  searchResults.add(i + 1);
                }
              }

              showSearchResultsAlertDialog(context, searchResults);
            },
          ),
        ],
      ),
    );
  }

  void showSearchResultsAlertDialog(
      BuildContext context, List<int> searchResults) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          //title: Text(''),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('The vehicle you are searching for is in slot number:'),
                for (int result in searchResults)
                  Text(
                    '$result',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
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
