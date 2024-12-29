import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  User? _user;
  File? _imageFile;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _nameController.text = _user?.displayName ?? '';
    _getUserProfileData();
  }

  Future<void> _getUserProfileData() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(_user?.uid).get();
      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          setState(() {
            _phoneNumberController.text = data['phoneNumber'] ?? '';
            _profileImageUrl = data['profileImageUrl'];
          });
        }
      }
    } catch (e) {
      print('Error fetching user profile data: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImageToStorage();
    }
  }

  Future<void> _uploadImageToStorage() async {
    try {
      final ref = _storage.ref().child('profile_images').child('${_user?.uid}.jpg');
      await ref.putFile(_imageFile!);
      final imageUrl = await ref.getDownloadURL();

      setState(() {
        _profileImageUrl = imageUrl;
      });

      await _firestore.collection('users').doc(_user?.uid).set({
        'profileImageUrl': imageUrl,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error uploading profile image: $e');
    }
  }

  Future<void> _updateProfile() async {
    try {
      await _user?.updateProfile(displayName: _nameController.text);
      await _user?.reload();
      _user = _auth.currentUser;

      await _firestore.collection('users').doc(_user?.uid).set({
        'displayName': _nameController.text,
        'email': _user?.email,
        'phoneNumber': _phoneNumberController.text,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : null,
                child: _profileImageUrl == null
                    ? Icon(Icons.camera_alt, size: 50)
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
              ),
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
