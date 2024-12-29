import 'package:attendance_system/user/auth_screen/user_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'edit_profile.dart'; // Import EditProfileScreen

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String? _phoneNumber;
  String? _profileImageUrl; // Add profile image URL variable

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    _user = _auth.currentUser;
    if (_user != null) {
      try {
        DocumentSnapshot snapshot = await _firestore.collection('users').doc(_user!.uid).get();
        if (snapshot.exists) {
          Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
          if (data != null) {
            setState(() {
              _phoneNumber = data['phoneNumber'];
              _profileImageUrl = data['profileImageUrl']; // Get profile image URL
            });
          }
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login'); // Adjust the route name accordingly
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                    ? NetworkImage(_profileImageUrl!)
                    : null,
                child: _profileImageUrl == null || _profileImageUrl!.isEmpty
                    ? Text(
                  _user?.displayName?.substring(0, 1) ?? 'U',
                  style: TextStyle(fontSize: 40, color: Colors.white),
                )
                    : null,
              ),
              SizedBox(height: 20),
              Text(
                _user?.displayName ?? 'Student Name',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                _user?.email ?? 'user@example.com',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              Text(
                _phoneNumber ?? 'Phone Number',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Navigate to Edit Profile screen
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfileScreen()),
                  );
                  _getUserInfo(); // Refresh profile info after editing
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                ),
                child: Text('Edit Profile'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (builder) => LoginScreen()));
                },
                onLongPress: _logout,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                ),
                child: Text('LogOut'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
