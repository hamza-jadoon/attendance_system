import 'package:attendance_system/admin/admin_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<bool> isAdminEmail(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('admins').doc(email).get();
      return snapshot.exists; // Check if admin email exists
    } catch (e) {
      print("Error checking admin email: $e");
      return false;
    }
  }

  void _login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // Basic validation
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      setState(() {
        errorMessage = "Please enter both email and password.";
        isLoading = false;
      });
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (await isAdminEmail(userCredential.user!.email!)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminDashboard()),
        );
      } else {
        await FirebaseAuth.instance.signOut();
        setState(() {
          errorMessage = "You are not authorized to access this application.";
        });
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        setState(() {
          errorMessage = "Incorrect email or password.";
        });
      } else {
        setState(() {
          errorMessage = "An error occurred. Please try again.";
        });
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _forgotPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        errorMessage = "Please enter your email to reset password.";
      });
      return;
    }

    FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset email sent!")),
      );
    }).catchError((e) {
      setState(() {
        errorMessage = "Failed to send reset email.";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Login"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade800],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              margin: EdgeInsets.symmetric(horizontal: 24),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Admin Login",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email, color: Colors.deepPurple),
                        labelText: "Email",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        fillColor: Colors.grey.shade100,
                        filled: true,
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Colors.deepPurple),
                        labelText: "Password",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        fillColor: Colors.grey.shade100,
                        filled: true,
                      ),
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isLoading ? null : _login,
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Login", style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: _forgotPassword,
                      child: Text("Forgot Password?", style: TextStyle(color: Colors.deepPurple)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
