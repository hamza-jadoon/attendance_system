import 'package:attendance_system/user/attendance_records.dart';
import 'package:attendance_system/user/auth_screen/user_login_screen.dart';
import 'package:attendance_system/user/leave_request_screen.dart';
import 'package:attendance_system/user/profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class UserDashboard extends StatefulWidget {
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool hasMarkedAttendance = false;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    _checkAttendanceStatus();
    _scheduleAttendanceReset();
  }
  Future<void> _getUserInfo() async {
    User? user = _auth.currentUser;
    setState(() {
      _user = user;
    });
  }

  Future<void> _checkAttendanceStatus() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    final snapshot = await FirebaseFirestore.instance
        .collection('attendance_records')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
        .get();

    setState(() {
      hasMarkedAttendance = snapshot.docs.isNotEmpty;
    });
  }


  // Mark attendance with user input
  Future<void> _markAttendance() async {
    if (hasMarkedAttendance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Attendance already marked for today!")),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userEmail = FirebaseAuth.instance.currentUser!.email;

    String? studentName;
    String? rollNo;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter Your Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Student Name'),
                onChanged: (value) {
                  studentName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Roll No'),
                onChanged: (value) {
                  rollNo = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (studentName != null && rollNo != null) {
                  Navigator.of(context).pop(); // Close dialog
                  _saveAttendance(userId, userEmail!, studentName!, rollNo!);
                }
              },
              child: Text("Mark Attendance"),
            ),
          ],
        );
      },
    );
  }

  // Save attendance record to Firestore
  Future<void> _saveAttendance(
      String userId,
      String userEmail,
      String studentName,
      String rollNo) async {
    DocumentReference docRef =
    await FirebaseFirestore.instance.collection('attendance_records').add({
      'userId': userId,
      'email': userEmail,
      'name': studentName,
      'rollNo': rollNo,
      'date': Timestamp.now(),
      'status': 'present',
    });

    DocumentSnapshot snapshot =
    await FirebaseFirestore.instance.collection(
        'attendance_records').doc(docRef.id).get();
    print("Saved attendance record: ${snapshot.data()}");

    setState(() {
      hasMarkedAttendance = true; // Update the UI
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Attendance marked successfully!")),
    );
  }

  // Reset attendance status at midnight
  void _scheduleAttendanceReset() {
    DateTime now = DateTime.now();
    DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1);

    Duration durationUntilMidnight = nextMidnight.difference(now);
    Timer(durationUntilMidnight, () {
      setState(() {
        hasMarkedAttendance = false; // Reset attendance status
      });
      _scheduleAttendanceReset(); // Reschedule for the next day
    });
  }

  // Navigate to Leave Request screen
  void _navigateToLeaveRequest() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LeaveRequestScreen()),
    );
  }

  // Navigate to View Attendance screen
  void _navigateToViewAttendance() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AttendanceRecords()),
    );
  }

  // Navigate to Edit Profile screen
  void _navigateToEditProfilePicture() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen()), // Pass userID appropriately
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
    // Handle navigation based on index if necessary
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance App"),
      ),
      drawer: Drawer(
        width: 240,
        backgroundColor: Colors.grey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 50),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.deepPurpleAccent,
                child: Text(
                  _user?.displayName?.substring(0, 1) ?? 'U',
                  style: TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              Text(
                _user?.displayName ?? 'Student Name',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              _buildDrawerItem(
                icon: Icons.person,
                title: 'Profile',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                },
              ),
              _buildDrawerItem(
                icon: Icons.settings,
                title: 'Settings',
                onTap: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
                },
              ),
              _buildDrawerItem(
                icon: Icons.login,
                title: 'Logout',
                onTap: () async {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                },
              ),
            ],
          ),
        ),
      ), // You can add drawer items if needed
      body: Container(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          children: [
            const Text(
              'Mark Your Attendance',
              style: TextStyle( fontSize: 35),
            ),
            const SizedBox(height: 50),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20.0,
                mainAxisSpacing: 20.0,
                children: [
                  _buildGridCard(
                    context: context,
                    icon: Icons.check_circle,
                    title: hasMarkedAttendance
                        ? "Attendance Marked"
                        : 'Mark Attendance',
                    onTap: hasMarkedAttendance ? null : _markAttendance,
                    color: hasMarkedAttendance ? Colors.teal : Colors.purple,
                  ),
                  _buildGridCard(
                    context: context,
                    icon: Icons.request_page,
                    title: 'Leave Request',
                    onTap: _navigateToLeaveRequest,
                    color: Colors.green,
                  ),
                  _buildGridCard(
                    context: context,
                    icon: Icons.visibility,
                    title: 'View Attendance',
                    onTap: _navigateToViewAttendance,
                    color: Colors.orange,
                  ),
                  _buildGridCard(
                    context: context,
                    icon: Icons.person,
                    title: ' Profile',
                    onTap: _navigateToEditProfilePicture,
                    color: Colors.cyan,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.book),
            //   label: 'Lessons',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          unselectedItemColor: Colors.black,
          // Set the background color here
      ),
    );
  }
  }

  // Build grid card widget
  Widget _buildGridCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap}) {
  return ListTile(
    leading: Icon(icon, color: Colors.deepPurple),
    title: Text(
      title,
      style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
    ),
    onTap: onTap,
  );
}