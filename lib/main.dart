import 'package:attendance_system/admin/admin_leave.dart';
import 'package:attendance_system/admin/admin_dashboard.dart';
import 'package:attendance_system/user/auth_screen/user_signup_screen.dart';
import 'package:attendance_system/user/leave_request_screen.dart';
import 'package:attendance_system/user/user_dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'admin/admin_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Montserrat', // A unique font for a modern look
      ),
      home: FrontScreen(),
    );
  }
}

class FrontScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[800]!, Colors.blue[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle decoration
              Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.blue[400]?.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.green[400]?.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Main Card
              Card(
                elevation: 20,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                margin: EdgeInsets.symmetric(horizontal: 30),
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Attendance Management System',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                      // Admin Button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AdminLoginScreen()),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blueAccent, Colors.blue],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 20,
                                  child: Icon(Icons.admin_panel_settings, color: Colors.blueAccent),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Admin',
                                  style: TextStyle(fontSize: 20, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // User Button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UserSignupScreen()),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green, Colors.greenAccent],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 20,
                                  child: Icon(Icons.person, color: Colors.green),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'User',
                                  style: TextStyle(fontSize: 20, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}