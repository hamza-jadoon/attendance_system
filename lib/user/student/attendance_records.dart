import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

class AttendanceRecords extends StatefulWidget {
  const AttendanceRecords({super.key});

  @override
  State<AttendanceRecords> createState() => _AttendanceRecordsState();
}

class _AttendanceRecordsState extends State<AttendanceRecords> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(" Attendance Record"),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("attendance_records").snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshots) {
            if (snapshots.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshots.hasData && snapshots.data!.docs.isEmpty) {
              return const Center(child: Text("No attendance records found."));
            }

            var data = snapshots.data!.docs;

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                var recordData = data[index].data() as Map<String, dynamic>;

                // Format date and time
                DateTime dateTime = recordData['date'].toDate();
                String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
                String formattedTime = DateFormat('HH:mm:ss').format(dateTime);

                return ListTile(
                  title: Text("Date: $formattedDate, Time: $formattedTime"), // Show both date and time
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Student Name: ${recordData['name']}"),
                      Text("Roll No: ${recordData['rollNo']}"),
                      Text("Status: ${recordData['status']}"),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Icon(
                    recordData['status'] == 'present' ? Icons.check : Icons.close,
                    color: recordData['status'] == 'present' ? Colors.green : Colors.red,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
