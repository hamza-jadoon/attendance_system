import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students List'),
        backgroundColor: Colors.blueAccent,
      ),
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

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var student = snapshot.data!.docs[index];
                return ListTile(
                  title: Text(student['name']),
                  subtitle: Text(student['email']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteConfirmationDialog(context, student.id);
                    },
                  ),
                  onTap: () {
                    _showStudentDetailsDialog(context, student);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showStudentDetailsDialog(BuildContext context, QueryDocumentSnapshot student) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(student['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Email: ${student['email']}'),
              Text('Roll No: ${student['rollNo']}'),
              Text('Status: ${student['status']}'),
              // Add more fields if necessary
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String studentId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const Text('Are you sure you want to delete this student?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await deleteStudent(studentId);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteStudent(String studentId) async {
    try {
      await FirebaseFirestore.instance.collection('students').doc(studentId).delete();
      print('Student deleted successfully');
    } catch (e) {
      print('Error deleting student: $e');
    }
  }
}
