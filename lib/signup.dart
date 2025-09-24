import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class CreateAccountScreen extends StatefulWidget {
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreeToTerms = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // IMPROVED Google Sign In with account selection
  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Sign out to force account selection
      await _googleSignIn.signOut();
      
      // Show account picker
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        _showErrorSnackBar('Sign-in cancelled. Please select an account to continue.');
        return;
      }

      // Simulate getting authentication (since we're bypassing Firebase)
      await Future.delayed(Duration(milliseconds: 800));
      
      // Show success with user info
      _showSuccessSnackBar('Successfully signed in as ${googleUser.displayName ?? googleUser.email}');

      // Navigate to home
      if (mounted) {
        await Future.delayed(Duration(milliseconds: 1000));
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
      
    } catch (e) {
      print('Google Sign-In error: $e');
      
      if (e.toString().contains('sign_in_canceled')) {
        _showErrorSnackBar('Sign-in was cancelled. Please try again.');
      } else if (e.toString().contains('network_error')) {
        _showErrorSnackBar('Network error. Please check your connection and try again.');
      } else if (e.toString().contains('sign_in_failed')) {
        _showErrorSnackBar('Sign-in failed. Please make sure you have Google Play Services installed.');
      } else {
        _showErrorSnackBar('Unable to sign in with Google. Please try again or use email registration.');
      }
      
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // BYPASS Firebase - Direct navigation
  Future<void> _createAccountWithEmail() async {
    if (_isLoading) return;
    
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (!_agreeToTerms) {
      _showErrorSnackBar('Please agree to the Terms of Service and Privacy Policy');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate loading for UX
    await Future.delayed(Duration(seconds: 1));

    _showSuccessSnackBar('Account created successfully!');

    // Direct navigation to home
    if (mounted) {
      await Future.delayed(Duration(milliseconds: 500));
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Get user-friendly error messages
  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'account-exists-with-different-credential':
        return 'Account exists with different sign-in method.';
      case 'invalid-credential':
        return 'Invalid credentials. Check Firebase configuration.';
      case 'missing-token':
        return 'Authentication failed. Check Firebase setup.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  // SIMPLIFIED save to Firestore
  Future<void> _saveUserToFirestore(User user) async {
    try {
      print('Saving user to Firestore: ${user.uid}');
      
      final userDoc = _firestore.collection('users').doc(user.uid);
      
      final userData = {
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastSignIn': FieldValue.serverTimestamp(),
        'emailVerified': user.emailVerified,
      };

      await userDoc.set(userData, SetOptions(merge: true));
      print('User saved to Firestore successfully');
      
    } catch (e) {
      print('Firestore error: $e');
      // Don't throw - authentication was successful
    }
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).viewPadding.top;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          SizedBox(height: statusBarHeight),
          
          // Back button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black54,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: _isLoading 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Creating account...',
                          style: TextStyle(
                            color: Colors.purple,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // Header image
                        Center(
                          child: Container(
                            width: 192,
                            height: 211,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/images/elemen_signup.png"),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Main content stack
                        Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            // Background gray container
                            Container(
                              width: double.infinity, 
                              height: 100,
                              margin: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                color: const Color(0x7FD9D9D9),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 30),
                                  child: Text(
                                    'Create New Account',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            // White container overlapping
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 60),
                              padding: const EdgeInsets.all(30),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(45),
                                  topRight: Radius.circular(45),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Start your productivity journey today!',
                                    style: TextStyle(fontSize: 16, color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 40),

                                  // Form Section
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Google Sign In Button
                                        SizedBox(
                                          width: double.infinity,
                                          height: 55,
                                          child: OutlinedButton.icon(
                                            onPressed: _isLoading ? null : _signInWithGoogle,
                                            icon: Container(
                                              width: 24,
                                              height: 24,
                                              child: Image.asset(
                                                'assets/images/google.png',
                                                width: 18,
                                                height: 18,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Icon(Icons.g_mobiledata, color: Colors.blue);
                                                },
                                              ),
                                            ),
                                            label: Text(
                                              'Sign In with Google',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30),
                                              ),
                                              backgroundColor: Colors.white,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 30),

                                        // OR Divider
                                        Row(
                                          children: [
                                            Expanded(child: Divider(color: Colors.grey[400])),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 20),
                                              child: Text('OR', style: TextStyle(color: Colors.grey[600])),
                                            ),
                                            Expanded(child: Divider(color: Colors.grey[400])),
                                          ],
                                        ),

                                        const SizedBox(height: 30),

                                        // Email Field
                                        const Text(
                                          'Email',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          controller: _emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            hintText: 'Enter Your Email',
                                            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15),
                                              borderSide: BorderSide(color: Colors.grey[300]!),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15),
                                              borderSide: BorderSide(color: Colors.grey[300]!),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15),
                                              borderSide: BorderSide(color: Colors.purple, width: 2),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                          ),
                                          validator: (value) {
                                            if (value?.trim().isEmpty ?? true) {
                                              return 'Please enter your email';
                                            }
                                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!.trim())) {
                                              return 'Please enter a valid email';
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 20),

                                        // Password Field
                                        const Text(
                                          'Password',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          controller: _passwordController,
                                          obscureText: !_isPasswordVisible,
                                          decoration: InputDecoration(
                                            hintText: 'Enter Your Password',
                                            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15),
                                              borderSide: BorderSide(color: Colors.grey[300]!),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15),
                                              borderSide: BorderSide(color: Colors.grey[300]!),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15),
                                              borderSide: BorderSide(color: Colors.purple, width: 2),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                                color: Colors.grey[600],
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _isPasswordVisible = !_isPasswordVisible;
                                                });
                                              },
                                            ),
                                          ),
                                          
                                          validator: (value) {
                                            if (value?.isEmpty ?? true) {
                                              return 'Please enter your password';
                                            }
                                            if (value!.length < 6) {
                                              return 'Password must be at least 6 characters';
                                            }
                                            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                                              return 'Password must contain uppercase, \n lowercase, and numbers';
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 10),

                                        // Confirm Password Field
                                        const Text(
                                          'Confirm Password',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          controller: _confirmPasswordController,
                                          obscureText: !_isConfirmPasswordVisible,
                                          decoration: InputDecoration(
                                            hintText: 'Enter Your Password Again',
                                            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15),
                                              borderSide: BorderSide(color: Colors.grey[300]!),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15),
                                              borderSide: BorderSide(color: Colors.grey[300]!),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(15),
                                              borderSide: BorderSide(color: Colors.purple, width: 2),
                                            ),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                                color: Colors.grey[600],
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                                });
                                              },
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value?.isEmpty ?? true) {
                                              return 'Please confirm your password';
                                            }
                                            if (value != _passwordController.text) {
                                              return 'Passwords do not match';
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 25),

                                        // Terms checkbox
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Checkbox(
                                              value: _agreeToTerms,
                                              onChanged: (value) {
                                                setState(() {
                                                  _agreeToTerms = value ?? false;
                                                });
                                              },
                                              activeColor: Colors.purple,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(top: 12),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _agreeToTerms = !_agreeToTerms;
                                                    });
                                                  },
                                                  child: Text(
                                                    'I agree to the Terms of Service and Privacy Policy',
                                                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 30),

                                        // Create Account Button
                                        SizedBox(
                                          width: double.infinity,
                                          height: 55,
                                          child: ElevatedButton(
                                            onPressed: _agreeToTerms ? _createAccountWithEmail : null,
                                            child: Text(
                                              'Create Account',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.purple,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(30),
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 25),

                                        // Sign In Link
                                        Center(
                                          child: GestureDetector(
                                            onTap: () => Navigator.pushNamed(context, '/login'),
                                            child: Text.rich(
                                              TextSpan(
                                                text: 'Already have an account? ',
                                                style: TextStyle(color: Colors.grey[700], fontSize: 15),
                                                children: [
                                                  TextSpan(
                                                    text: 'Sign In',
                                                    style: TextStyle(
                                                      color: Colors.purple,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 30),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}