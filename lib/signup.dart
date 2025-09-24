import 'dart:async'; // Add this import for TimeoutException
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

  // Tambahkan instance GoogleSignIn
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ENHANCED: Google Sign In with better error handling and debugging
  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      print('=== GOOGLE SIGN-IN START ===');
      
      // Clean previous sessions first
      try {
        await GoogleSignIn().signOut();
        await FirebaseAuth.instance.signOut();
        print('Previous sessions cleaned');
      } catch (e) {
        print('Error cleaning sessions: $e');
      }
      
      // Add a small delay
      await Future.delayed(Duration(milliseconds: 300));
      
      // Configure GoogleSignIn with more specific settings
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
        // Add this if you have web client ID
        // serverClientId: 'YOUR_WEB_CLIENT_ID_FROM_FIREBASE',
      );
      
      print('GoogleSignIn configured');
      print('Starting sign-in process...');
      
      // Check if Google Play Services are available
      final bool isAvailable = await googleSignIn.isSignedIn();
      print('Google Services available: $isAvailable');
      
      // Trigger the authentication flow with timeout
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn().timeout(
        Duration(seconds: 60),
        onTimeout: () {
          print('Google Sign-In timed out');
          return null;
        },
      );
      
      if (googleUser == null) {
        print('No Google user selected or sign-in cancelled');
        _showErrorSnackBar('Sign-in was cancelled or failed');
        return;
      }

      print('✓ Google user selected: ${googleUser.email}');
      print('User ID: ${googleUser.id}');
      print('Display Name: ${googleUser.displayName}');

      // Get authentication details with error checking
      print('Getting authentication tokens...');
      final GoogleSignInAuthentication? googleAuth;
      
      try {
        googleAuth = await googleUser.authentication.timeout(
          Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Token fetch timeout', Duration(seconds: 30));
          },
        );
      } catch (e) {
        print('Error getting authentication: $e');
        throw FirebaseAuthException(
          code: 'auth-timeout',
          message: 'Failed to get authentication tokens: $e'
        );
      }

      // Validate tokens
      if (googleAuth == null) {
        print('❌ Google auth is null');
        throw FirebaseAuthException(
          code: 'null-auth',
          message: 'Authentication object is null'
        );
      }

      if (googleAuth.accessToken == null) {
        print('❌ Access token is null');
        throw FirebaseAuthException(
          code: 'no-access-token',
          message: 'Access token not received. Check Firebase configuration and SHA-1 fingerprint.'
        );
      }

      if (googleAuth.idToken == null) {
        print('❌ ID token is null');
        throw FirebaseAuthException(
          code: 'no-id-token',
          message: 'ID token not received. Verify SHA-1 fingerprint in Firebase Console.'
        );
      }

      print('✓ Tokens received successfully');
      print('Access Token length: ${googleAuth.accessToken!.length}');
      print('ID Token length: ${googleAuth.idToken!.length}');

      // Create Firebase credential
      print('Creating Firebase credential...');
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('✓ Credential created');
      print('Authenticating with Firebase...');

      // Sign in to Firebase with credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw FirebaseAuthException(
            code: 'firebase-timeout',
            message: 'Firebase authentication timed out'
          );
        },
      );
      // final userCredential = await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      
      final User? user = userCredential.user;
      if (user == null) {
        print('❌ User is null after Firebase sign-in');
        throw FirebaseAuthException(
          code: 'null-user',
          message: 'User object is null after authentication'
        );
      }

      print('✓ Firebase authentication successful!');
      print('User UID: ${user.uid}');
      print('User Email: ${user.email}');
      print('User Name: ${user.displayName}');
      print('Email Verified: ${user.emailVerified}');
      
      // Save user data to Firestore
      print('Saving user to Firestore...');
      try {
        await _saveUserToFirestore(user);
        print('✓ User saved to Firestore');
      } catch (e) {
        print('⚠️ Firestore save error (non-critical): $e');
        // Don't fail the entire process for Firestore errors
      }

      print('=== GOOGLE SIGN-IN COMPLETED SUCCESSFULLY ===');

      // Show success message
      _showSuccessSnackBar('Successfully signed in with Google!');

      // Navigate to home screen
      if (mounted) {
        await Future.delayed(Duration(milliseconds: 1500));
        Navigator.pushReplacementNamed(context, '/home');
      }
      
    } on TimeoutException catch (e) {
      print('❌ Timeout Error: $e');
      _showErrorSnackBar('Connection timeout. Please check your internet and try again.');
      
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      
      String userMessage;
      String debugHint;
      
      switch (e.code) {
        case 'account-exists-with-different-credential':
          userMessage = 'This email is already registered with a different method';
          debugHint = 'Try signing in with email/password instead';
          break;
        case 'invalid-credential':
        case 'invalid-verification-code':
          userMessage = 'Invalid Google credentials';
          debugHint = 'SHA-1 fingerprint may be missing in Firebase Console';
          break;
        case 'operation-not-allowed':
          userMessage = 'Google Sign-In is not enabled for this app';
          debugHint = 'Enable Google Sign-In in Firebase Console → Authentication';
          break;
        case 'user-disabled':
          userMessage = 'This account has been disabled';
          debugHint = 'Contact support if this is an error';
          break;
        case 'no-access-token':
        case 'no-id-token':
          userMessage = 'Failed to get Google authentication tokens';
          debugHint = 'Check SHA-1 fingerprint in Firebase Console';
          break;
        case 'network-request-failed':
          userMessage = 'Network error occurred';
          debugHint = 'Check your internet connection';
          break;
        case 'auth-timeout':
        case 'firebase-timeout':
          userMessage = 'Authentication timed out';
          debugHint = 'Try again with better internet connection';
          break;
        default:
          userMessage = 'Authentication failed';
          debugHint = e.message ?? 'Unknown error occurred';
      }
      
      print('User Message: $userMessage');
      print('Debug Hint: $debugHint');
      
      _showErrorSnackBar('$userMessage\n\nTip: $debugHint');
      
    } catch (e, stackTrace) {
      print('❌ Unexpected Error: $e');
      print('Stack Trace: $stackTrace');
      
      String errorMsg = 'Unexpected error occurred';
      if (e.toString().toLowerCase().contains('network')) {
        errorMsg = 'Network error - check internet connection';
      } else if (e.toString().toLowerCase().contains('timeout')) {
        errorMsg = 'Connection timeout - try again';
      }
      
      // _showErrorSnackBar('$errorMsg\n\nError: ${e.toString()}');
      
    } finally {
      print('Google Sign-In process finished');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Add success snackbar method
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Email/Password registration method
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

    try {
      print('Creating account with email: ${_emailController.text.trim()}');
      
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      print('Email account created successfully');
      
      // Send email verification
      await userCredential.user?.sendEmailVerification();
      
      // Save user data to Firestore
      await _saveUserToFirestore(userCredential.user!);

      _showSuccessSnackBar('Account created successfully!');

      // Navigate to home screen
      if (mounted) {
        await Future.delayed(Duration(milliseconds: 1000));
        Navigator.pushReplacementNamed(context, '/home');
      }

    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for that email';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred during registration';
      }
      _showErrorSnackBar(errorMessage);
      
    } catch (e) {
      print('Unexpected error: $e');
      _showErrorSnackBar('An unexpected error occurred. Please try again');
      
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Save user data to Firestore method
  Future<void> _saveUserToFirestore(User user) async {
    try {
      print('Saving user ${user.uid} to Firestore...');
      
      final userDocRef = _firestore.collection('users').doc(user.uid);
      
      // Check if user document already exists
      DocumentSnapshot userDoc = await userDocRef.get();

      Map<String, dynamic> userData = {
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'lastSignIn': FieldValue.serverTimestamp(),
        'provider': user.providerData.isNotEmpty 
            ? user.providerData.first.providerId 
            : 'password',
        'emailVerified': user.emailVerified,
      };

      if (!userDoc.exists) {
        // Create new user document
        userData['createdAt'] = FieldValue.serverTimestamp();
        await userDocRef.set(userData);
        print('New user document created');
      } else {
        // Update existing user document
        Map<String, dynamic> updateData = {
          'lastSignIn': FieldValue.serverTimestamp(),
          'emailVerified': user.emailVerified,
        };
        
        // Only update these fields if they have values
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          updateData['displayName'] = user.displayName!;
        }
        if (user.photoURL != null && user.photoURL!.isNotEmpty) {
          updateData['photoURL'] = user.photoURL!;
        }
        
        await userDocRef.update(updateData);
        print('Existing user document updated');
      }
      
    } catch (e) {
      print('Error saving user to Firestore: $e');
      // Don't throw here - authentication was successful
      // Just log the error and continue
    }
  }

  // Show error snackbar
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _isLoading 
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Please wait...',
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),

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
                          height: 115,
                          margin: EdgeInsets.symmetric(horizontal: 16),
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
                          margin: const EdgeInsets.only(top: 70, left: 16, right: 16),
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(45),
                              topRight: Radius.circular(45),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, -2),
                                blurRadius: 8,
                              ),
                            ],
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
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.2),
                                                spreadRadius: 1,
                                                blurRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Image.asset(
                                              'assets/images/google.png',
                                              width: 18,
                                              height: 18,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: 18,
                                                  height: 18,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                      colors: [Colors.blue, Colors.red, Colors.yellow, Colors.green],
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      'G',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        label: Text(
                                          _isLoading ? 'Signing in...' : 'Sign In with Google',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: _isLoading ? Colors.grey : Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                              color: Colors.grey[300]!, width: 1.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          backgroundColor: Colors.white,
                                          elevation: 0,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 30),

                                    // OR Divider
                                    Row(
                                      children: [
                                        Expanded(
                                            child: Divider(
                                                color: Colors.grey[400], thickness: 1)),
                                        Padding(
                                          padding:
                                              const EdgeInsets.symmetric(horizontal: 20),
                                          child: Text(
                                            'OR',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                            child: Divider(
                                                color: Colors.grey[400], thickness: 1)),
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
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                        hintText: 'Enter Your Email',
                                        hintStyle: TextStyle(
                                            color: Colors.grey[500], fontSize: 15),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                              color: Colors.grey[300]!, width: 1),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                              color: Colors.grey[300]!, width: 1),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: const BorderSide(
                                              color: Colors.purple, width: 2),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: const BorderSide(
                                              color: Colors.red, width: 1),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 18),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                            .hasMatch(value.trim())) {
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
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                        hintText: 'Enter Your Password',
                                        hintStyle: TextStyle(
                                            color: Colors.grey[500], fontSize: 15),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                              color: Colors.grey[300]!, width: 1),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                              color: Colors.grey[300]!, width: 1),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: const BorderSide(
                                              color: Colors.purple, width: 2),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: const BorderSide(
                                              color: Colors.red, width: 1),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 18),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isPasswordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: Colors.grey[600],
                                            size: 22,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isPasswordVisible = !_isPasswordVisible;
                                            });
                                          },
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 20),

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
                                      textInputAction: TextInputAction.done,
                                      decoration: InputDecoration(
                                        hintText: 'Enter Your Password Again',
                                        hintStyle: TextStyle(
                                            color: Colors.grey[500], fontSize: 15),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                              color: Colors.grey[300]!, width: 1),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                              color: Colors.grey[300]!, width: 1),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: const BorderSide(
                                              color: Colors.purple, width: 2),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: const BorderSide(
                                              color: Colors.red, width: 1),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 18),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isConfirmPasswordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: Colors.grey[600],
                                            size: 22,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isConfirmPasswordVisible =
                                                  !_isConfirmPasswordVisible;
                                            });
                                          },
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please confirm your password';
                                        }
                                        if (value != _passwordController.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 25),

                                    // Terms and Conditions
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
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
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
                                              child: Text.rich(
                                                TextSpan(
                                                  text: 'I agree to the ',
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                    fontSize: 14,
                                                  ),
                                                  children: const [
                                                    TextSpan(
                                                      text: 'Terms of Service',
                                                      style: TextStyle(
                                                        color: Colors.purple,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    TextSpan(text: ' and '),
                                                    TextSpan(
                                                      text: 'Privacy Policy',
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
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 30),

                                    // Create Account Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 55,
                                      child: ElevatedButton(
                                        onPressed: (_agreeToTerms && !_isLoading)
                                            ? _createAccountWithEmail
                                            : null,
                                        child: Text(
                                          _isLoading ? 'Creating Account...' : 'Create Account',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purple,
                                          disabledBackgroundColor: Colors.grey[300],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          elevation: 2,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 25),

                                    // Sign In Link
                                    Align(
                                      alignment: Alignment.center,
                                      child: GestureDetector(
                                        onTap: _isLoading ? null : () {
                                          Navigator.pushNamed(context, '/login');
                                        },
                                        child: Text.rich(
                                          TextSpan(
                                            text: 'Already have an account? ',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 15,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'Sign In',
                                                style: TextStyle(
                                                  color: _isLoading ? Colors.grey : Colors.purple,
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

// Login Screen

// Home Screen
// class HomeScreen extends StatelessWidget {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   @override
//   Widget build(BuildContext context) {
//     final User? user = _auth.currentUser;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Welcome'),
//         backgroundColor: Colors.purple,
//         foregroundColor: Colors.white,
//         automaticallyImplyLeading: false,
//         elevation: 0,
//         actions: [
//           PopupMenuButton<String>(
//             icon: Icon(Icons.more_vert),
//             onSelected: (value) async {
//               if (value == 'logout') {
//                 await _showLogoutDialog(context);
//               } else if (value == 'profile') {
//                 _showUserProfile(context, user);
//               }
//             },
//             itemBuilder: (BuildContext context) => [
//               PopupMenuItem<String>(
//                 value: 'profile',
//                 child: Row(
//                   children: [
//                     Icon(Icons.person, color: Colors.purple),
//                     SizedBox(width: 8),
//                     Text('Profile'),
//                   ],
//                 ),
//               ),
//               PopupMenuItem<String>(
//                 value: 'logout',
//                 child: Row(
//                   children: [
//                     Icon(Icons.logout, color: Colors.red),
//                     SizedBox(width: 8),
//                     Text('Logout'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: Center(
//         child: Padding(
//           padding: EdgeInsets.all(20),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // User Avatar
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.purple, width: 3),
//                 ),
//                 child: user?.photoURL != null
//                     ? ClipOval(
//                         child: Image.network(
//                           user!.photoURL!,
//                           width: 94,
//                           height: 94,
//                           fit: BoxFit.cover,
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return CircularProgressIndicator(
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
//                             );
//                           },
//                           errorBuilder: (context, error, stackTrace) {
//                             return Icon(
//                               Icons.person,
//                               size: 60,
//                               color: Colors.purple,
//                             );
//                           },
//                         ),
//                       )
//                     : Icon(
//                         Icons.person,
//                         size: 60,
//                         color: Colors.purple,
//                       ),
//               ),
              
//               SizedBox(height: 20),
              
//               Text(
//                 'Welcome!',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
              
//               SizedBox(height: 10),
              
//               Text(
//                 user?.displayName ?? 'User',
//                 style: TextStyle(
//                   fontSize: 22,
//                   color: Colors.grey[700],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
              
//               SizedBox(height: 8),
              
//               Text(
//                 user?.email ?? 'No email',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey[600],
//                 ),
//               ),
              
//               SizedBox(height: 30),
              
//               // Account Information Card
//               Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Account Information',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       SizedBox(height: 15),
//                       _buildInfoRow('UID', user?.uid ?? 'N/A'),
//                       _buildInfoRow('Provider', user?.providerData.isNotEmpty == true 
//                           ? user!.providerData.first.providerId 
//                           : 'N/A'),
//                       _buildInfoRow('Email Verified', user?.emailVerified == true ? 'Yes' : 'No'),
//                       _buildInfoRow('Created', user?.metadata.creationTime?.toString().split(' ')[0] ?? 'N/A'),
//                     ],
//                   ),
//                 ),
//               ),
              
//               SizedBox(height: 30),
              
//               // Action Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Welcome to your productivity app!'),
//                         backgroundColor: Colors.green,
//                         behavior: SnackBarBehavior.floating,
//                       ),
//                     );
//                   },
//                   icon: Icon(Icons.rocket_launch, color: Colors.white),
//                   label: Text(
//                     'Start Your Journey',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.purple,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     elevation: 2,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               '$label:',
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[700],
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: Colors.black87,
//               ),
//               overflow: TextOverflow.ellipsis,
//               maxLines: 2,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _showLogoutDialog(BuildContext context) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Logout'),
//           content: Text('Are you sure you want to logout?'),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             ElevatedButton(
//               child: Text('Logout'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//               ),
//               onPressed: () async {
//                 Navigator.of(context).pop();
//                 await _performLogout(context);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _performLogout(BuildContext context) async {
//     try {
//       await _auth.signOut();
//       await GoogleSignIn().signOut();
      
//       if (context.mounted) {
//         Navigator.pushReplacementNamed(context, '/');
//       }
//     } catch (e) {
//       print('Error during logout: $e');
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error during logout. Please try again.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   void _showUserProfile(BuildContext context, User? user) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('User Profile'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (user?.photoURL != null)
//                 Center(
//                   child: CircleAvatar(
//                     radius: 40,
//                     backgroundImage: NetworkImage(user!.photoURL!),
//                   ),
//                 ),
//               SizedBox(height: 16),
//               Text('Name: ${user?.displayName ?? 'Not provided'}'),
//               SizedBox(height: 8),
//               Text('Email: ${user?.email ?? 'Not provided'}'),
//               SizedBox(height: 8),
//               Text('Verified: ${user?.emailVerified == true ? 'Yes' : 'No'}'),
//             ],
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('Close'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }