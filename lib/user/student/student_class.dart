import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String userId;
  final String name;
  final String rollNo;
  final String email;
  final DateTime date;
  final String status;

  Student({
    required this.userId,
    required this.name,
    required this.rollNo,
    required this.email,
    required this.date,
    required this.status,
  });

  factory Student.fromFirestore(Map<String, dynamic> data) {
    return Student(
      userId: data['userId'],
      email: data['email'],
      name: data['name'],
      rollNo: data['roll_number'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'],
    );
  }
}
