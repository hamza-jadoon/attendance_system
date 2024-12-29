import 'package:attendance_system/admin/admin_leave.dart';
import 'package:attendance_system/admin/student_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: Drawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('students').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final totalStudents = snapshot.data!.docs.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: const Text(
                    'Overview',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OverviewCard(
                      title: 'Total Students',
                      value: '$totalStudents',
                      color: Colors.tealAccent,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (builder) => StudentListScreen()),
                        );
                      },
                    ),
                    FutureBuilder<double>(
                      future: _calculateAttendancePercentage(),
                      builder: (context, snapshot) {
                        String attendancePercentage = '0%';
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          attendancePercentage = 'Loading...';
                        } else if (snapshot.hasError) {
                          attendancePercentage = 'Error';
                        } else {
                          attendancePercentage = '${snapshot.data?.toStringAsFixed(2)}%';
                        }

                        return OverviewCard(
                          title: 'Attendance',
                          value: attendancePercentage,
                          color: Colors.lightGreenAccent,
                          onPressed: () {}, // Implement attendance logic here
                        );
                      },
                    ),
                    FutureBuilder<int>(
                      future: _fetchPendingLeaveRequests(),
                      builder: (context, snapshot) {
                        String pendingLeaves = '0';
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          pendingLeaves = 'Loading...';
                        } else if (snapshot.hasError) {
                          pendingLeaves = 'Error';
                        } else {
                          pendingLeaves = snapshot.data.toString();
                        }

                        return OverviewCard(
                          title: 'Pending Requests',
                          value: pendingLeaves,
                          color: Colors.orangeAccent,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (builder) => AdminLeaveApprovalScreen()));
                          }, // Implement pending requests logic here
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Center(
                  child: const Text(
                    'Attendance Records',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('attendance_records').snapshots(),
                    builder: (context, attendanceSnapshot) {
                      if (attendanceSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (attendanceSnapshot.hasError) {
                        return Center(child: Text('Error: ${attendanceSnapshot.error}'));
                      }

                      final attendanceRecords = attendanceSnapshot.data!.docs;


                      return ListView.builder(
                        itemCount: attendanceRecords.length,
                        itemBuilder: (context, index) {
                          var record = attendanceRecords[index];
                          return ListTile(
                            title: Text(record['name'] ?? 'Unnamed Student'),
                            subtitle: Text('Date: ${record['date']?.toDate()?.toLocal().toString().split(' ')[0] ?? 'N/A'}'),
                            trailing: Text('Status: ${record['status'] ?? 'N/A'}'),
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _showAddStudentDialog(context),
                      child: const Text('Add New User'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {}, // Generate report logic here
                      child: const Text('Generate Report'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<double> _calculateAttendancePercentage() async {
    final attendanceRecordsSnapshot = await FirebaseFirestore.instance.collection('attendance_records').get();
    final totalClasses = attendanceRecordsSnapshot.docs.length;
    if (totalClasses == 0) return 0.0;

    final attendedClasses = attendanceRecordsSnapshot.docs.where((doc) => doc['status'] == 'Present').length;
    return (attendedClasses / totalClasses) * 100;
  }

  Future<int> _fetchPendingLeaveRequests() async {
    final leaveRequestsSnapshot = await FirebaseFirestore.instance.collection('leave_requests').where('status', isEqualTo: 'Pending').get();
    return leaveRequestsSnapshot.docs.length;
  }

  void _showAddStudentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final rollNoController = TextEditingController();
    final statusController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: rollNoController,
                  decoration: const InputDecoration(labelText: 'Roll Number'),
                ),
                TextField(
                  controller: statusController,
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text;
                final email = emailController.text;
                final rollNo = rollNoController.text;
                final status = statusController.text;

                if (name.isNotEmpty && email.isNotEmpty && rollNo.isNotEmpty && status.isNotEmpty) {
                  await addStudent(name, rollNo, email, status);
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
                }
              },
              child: const Text('Add User'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addStudent(String name, String rollNo, String email, String status) async {
    try {
      final newStudentRef = FirebaseFirestore.instance.collection('students').doc();
      await newStudentRef.set({
        'userId': newStudentRef.id,
        'name': name,
        'rollNo': rollNo,
        'email': email,
        'date': FieldValue.serverTimestamp(),
        'status': status,
      });
      print('Student added successfully');
    } catch (e) {
      print('Error adding Student: $e');
    }
  }
}

class OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final VoidCallback onPressed;

  const OverviewCard({
    required this.title,
    required this.value,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        color: color.withOpacity(0.7),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
