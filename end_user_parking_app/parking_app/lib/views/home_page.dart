import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      drawer: Drawer(
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 212, 214, 213),
                  ),
                  child: Text('Welcome'),
                ),
                ListTile(
                  title: Text('Profile'),
                  onTap: () {
                    // Handle navigation to option 1 page
                  },
                ),
                ListTile(
                  title: Text('History'),
                  onTap: () {
                    // Handle navigation to option 2 page
                  },
                ),
                Divider(),
                ListTile(
                  title: Text('Logout'),
                  onTap: () {
                    // Handle logout
                  },
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: () {
                    // Handle logout
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              // Add your Google Map widget here
              color: Colors.grey, // Placeholder color
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle Nearby Spaces option
                    // Navigate to nearby spaces screen or perform related actions
                  },
                  child: Text('Nearby Spaces'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle Search option
                    // Navigate to search screen or perform related actions
                  },
                  child: Text('Search'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
