import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminLeaveApprovalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leave Approval')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('leaves').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print('No documents found or data is null.'); // Debug log
            return Center(child: Text('No leave requests found.'));
          }

          // Debug log to see how many documents were fetched
          print('Documents fetched: ${snapshot.data!.docs.length}');

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>?;

              // Extracting and formatting the data
              String leaveStartDate;
              String leaveEndDate;
              String studentName;
              String reason;

              if (data != null) {
                // Convert start and end date from Timestamp
                Timestamp startDate = data['start_date'];
                Timestamp endDate = data['end_date'];

                leaveStartDate = startDate.toDate().toLocal().toString(); // Convert to readable format
                leaveEndDate = endDate.toDate().toLocal().toString(); // Convert to readable format
                studentName = data['student_name'] ?? 'Unknown Student';
                reason = data['reason'] ?? 'No reason provided';
              } else {
                leaveStartDate = 'No start date available';
                leaveEndDate = 'No end date available';
                studentName = 'Unknown Student';
                reason = 'No reason provided';
              }

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('Leave Request from: $studentName'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reason: $reason'),
                      Text('Start Date: $leaveStartDate'),
                      Text('End Date: $leaveEndDate'),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () async {
                          // Handle leave approval action
                          await FirebaseFirestore.instance
                              .collection('leaves')
                              .doc(doc.id)
                              .update({'status': 'approved'});
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Leave request approved.')));
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () async {
                          // Handle leave rejection action
                          await FirebaseFirestore.instance
                              .collection('leaves')
                              .doc(doc.id)
                              .update({'status': 'rejected'});
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Leave request rejected.')));
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
