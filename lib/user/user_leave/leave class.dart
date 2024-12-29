import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveRequest {
  final String name;
  final String rollNo;
  final String status; // "Pending", "Approved", or "Rejected"
  final DateTime leaveStartDate;
  final DateTime leaveEndDate;
  final String reason; // Reason for leave

  LeaveRequest({
    required this.name,
    required this.rollNo,
    required this.status,
    required this.leaveStartDate,
    required this.leaveEndDate,
    required this.reason,
  });

  factory LeaveRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaveRequest(
      name: data['userId'],
      rollNo: doc.id,
      status: data['status'],
      leaveStartDate: (data['leaveStartDate'] as Timestamp).toDate(),
      leaveEndDate: (data['leaveEndDate'] as Timestamp).toDate(),
      reason: data['reason'], // Include the reason field
    );
  }
}
