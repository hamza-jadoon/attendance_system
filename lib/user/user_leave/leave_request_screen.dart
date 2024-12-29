import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LeaveRequestScreen extends StatefulWidget {
  @override
  _LeaveRequestScreenState createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollNoController = TextEditingController();
  final _reasonController = TextEditingController();
  DateTime? _leaveStartDate;
  DateTime? _leaveEndDate;

  Future<void> _submitLeaveRequest() async {
    if (_formKey.currentState!.validate() && _leaveStartDate != null && _leaveEndDate != null) {
      // Prepare data for Firestore
      final leaveRequestData = {
        'userId': _nameController.text,
        'rollNo': _rollNoController.text,
        'status': 'Pending',
        'reason': _reasonController.text,
        'leaveStartDate': Timestamp.fromDate(_leaveStartDate!),
        'leaveEndDate': Timestamp.fromDate(_leaveEndDate!),
      };

      // Add leave request to Firestore
      await FirebaseFirestore.instance.collection('leave_requests').add(leaveRequestData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Leave request submitted successfully.')));

      // Clear form
      _formKey.currentState!.reset();
      _nameController.clear();
      _rollNoController.clear();
      _reasonController.clear();
      setState(() {
        _leaveStartDate = null;
        _leaveEndDate = null;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? DateTime.now() : DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _leaveStartDate = picked;
        } else {
          _leaveEndDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Request'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _rollNoController,
                decoration: InputDecoration(labelText: 'Roll No'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your roll number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(labelText: 'Reason for Leave'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the reason for leave';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_leaveStartDate == null
                      ? 'Start Date: Not selected'
                      : 'Start Date: ${DateFormat('yyyy-MM-dd').format(_leaveStartDate!)}'),
                  ElevatedButton(
                    onPressed: () => _selectDate(context, true),
                    child: Text('Select Start Date'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_leaveEndDate == null
                      ? 'End Date: Not selected'
                      : 'End Date: ${DateFormat('yyyy-MM-dd').format(_leaveEndDate!)}'),
                  ElevatedButton(
                    onPressed: () => _selectDate(context, false),
                    child: Text('Select End Date'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitLeaveRequest,
                child: Text('Submit Leave Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
