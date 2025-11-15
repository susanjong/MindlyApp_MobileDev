import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notesapp/widgets/snackbar.dart';
import 'package:notesapp/widgets/button.dart';
import 'package:notesapp/routes/routes.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _agreeToTerms = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isConfirmPasswordFocused = false;

  // Error messages
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();

    // Listen to email field focus
    _emailFocusNode.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus;
      });
    });

    // Listen to password field focus
    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
    });

    // Listen to confirm password field focus
    _confirmPasswordFocusNode.addListener(() {
      setState(() {
        _isConfirmPasswordFocused = _confirmPasswordFocusNode.hasFocus;
      });
    });

    // Add listeners to clear errors when typing
    _emailController.addListener(() {
      if (_emailError != null) {
        setState(() {
          _emailError = null;
        });
      }
    });

    _passwordController.addListener(() {
      if (_passwordError != null) {
        setState(() {
          _passwordError = null;
        });
      }
    });

    _confirmPasswordController.addListener(() {
      if (_confirmPasswordError != null) {
        setState(() {
          _confirmPasswordError = null;
        });
      }
    });
  }

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        Snackbar.error(context, 'Sign-in cancelled. Please select an account to continue.');
        return;
      }

      Snackbar.success(context, 'Successfully signed in as ${googleUser.displayName ?? googleUser.email}');
      if (mounted) {
        await Future.delayed(Duration(milliseconds: 1000));
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      print('Google Sign-In error: $e');

      if (e.toString().contains('sign_in_canceled')) {
        Snackbar.error(context, 'Sign-in was cancelled. Please try again.');
      } else if (e.toString().contains('network_error')) {
        Snackbar.error(context, 'Network error. Please check your connection and try again.');
      } else if (e.toString().contains('sign_in_failed')) {
        Snackbar.error(context, 'Sign-in failed. Please make sure you have Google Play Services installed.');
      } else {
        Snackbar.error(context, 'Unable to sign in with Google. Please try again or use email registration.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateFields() {
    bool isValid = true;

    // Validate email
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _emailError = 'Please enter your email';
      });
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
      setState(() {
        _emailError = 'Please enter a valid email';
      });
      isValid = false;
    }

    // Validate password
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Please enter your password';
      });
      isValid = false;
    } else if (_passwordController.text.length < 6) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters';
      });
      isValid = false;
    } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(_passwordController.text)) {
      setState(() {
        _passwordError = 'Password must contain uppercase, lowercase, and numbers';
      });
      isValid = false;
    }

    // Validate confirm password
    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Please confirm your password';
      });
      isValid = false;
    } else if (_confirmPasswordController.text != _passwordController.text) {
      setState(() {
        _confirmPasswordError = 'Password does not match';
      });
      isValid = false;
    }

    return isValid;
  }

  Future<void> _createAccountWithEmail() async {
    if (_isLoading) return;

    if (!_validateFields()) {
      return;
    }

    if (!_agreeToTerms) {
      Snackbar.error(context, 'Please agree to the Terms of Service and Privacy Policy');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate account creation
    await Future.delayed(Duration(milliseconds: 500));

    Snackbar.success(context, 'Account created successfully!');
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Responsive values
    final double horizontalPadding = screenWidth > 600 ? 50 : 40;
    final double buttonWidth = screenWidth > 600
        ? (screenWidth * 0.4).clamp(360.0, 500.0)
        : (screenWidth - (horizontalPadding * 2)).clamp(280.0, 313.0);
    final double buttonHeight = screenWidth > 600 ? 45 : 38;
    final double titleFontSize = screenWidth > 600 ? 22 : 20;
    final double subtitleFontSize = screenWidth > 600 ? 16 : 15;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _isLoading
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD9D9D9)),
              ),
              SizedBox(height: 16),
              Text(
                'Please Wait...',
                style: GoogleFonts.poppins(
                  color: Colors.black,
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

              // Header image - Responsive
              Center(
                child: Container(
                  width: screenWidth > 600 ? 220 : 192,
                  height: screenWidth > 600 ? 240 : 211,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/signup_elemen.png"),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: double.infinity,
                    height: 108,
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: const Color(0x7FD9D9D9),
                      borderRadius: BorderRadius.circular(45),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: Text(
                          'Create New Account',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            letterSpacing: -0.40,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 54),
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 30),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth > 600 ? 320 : 270,
                          child: Text(
                            'Start your productivity journey today!',
                            style: GoogleFonts.poppins(
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              letterSpacing: -0.30,
                              height: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Google Sign In Button - Responsive
                              Container(
                                width: buttonWidth,
                                height: buttonHeight,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(width: 1, color: Colors.black),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _isLoading ? null : _signInWithGoogle,
                                    borderRadius: BorderRadius.circular(10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/google.png',
                                          width: 16,
                                          height: 16,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(Icons.g_mobiledata, color: Colors.blue, size: 16);
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Sign In with Google',
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: -0.30,
                                            height: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // OR Divider
                              SizedBox(
                                width: buttonWidth,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: Colors.black.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        'OR',
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w200,
                                          letterSpacing: -0.24,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: Colors.black.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 15),

                              // Form fields container with fixed width
                              SizedBox(
                                width: buttonWidth,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Email Field
                                    Text(
                                      'Email',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        letterSpacing: -0.26,
                                        height: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 36,
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: _isEmailFocused ? 2 : 1,
                                              color: _emailError != null
                                                  ? const Color(0xFFD4183D)
                                                  : (_isEmailFocused ? const Color(0xFF5784EB) : Colors.black),
                                            ),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: TextFormField(
                                            controller: _emailController,
                                            focusNode: _emailFocusNode,
                                            keyboardType: TextInputType.emailAddress,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w300,
                                              letterSpacing: -0.26,
                                              height: 1,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Enter Your Email',
                                              hintStyle: GoogleFonts.poppins(
                                                color: Colors.black,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w300,
                                                letterSpacing: -0.26,
                                                height: 1,
                                              ),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                        if (_emailError != null) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            _emailError!,
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFFD4183D),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w300,
                                              letterSpacing: -0.20,
                                              height: 1,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),

                                    const SizedBox(height: 15),

                                    // Password Field
                                    Text(
                                      'Password',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        letterSpacing: -0.26,
                                        height: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 36,
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: _isPasswordFocused ? 2 : 1,
                                              color: _passwordError != null
                                                  ? const Color(0xFFD4183D)
                                                  : (_isPasswordFocused ? const Color(0xFF5784EB) : Colors.black),
                                            ),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: _passwordController,
                                                  focusNode: _passwordFocusNode,
                                                  obscureText: !_isPasswordVisible,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w300,
                                                    letterSpacing: -0.26,
                                                    height: 1,
                                                  ),
                                                  decoration: InputDecoration(
                                                    hintText: 'Enter Your Password',
                                                    hintStyle: GoogleFonts.poppins(
                                                      color: Colors.black,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w300,
                                                      letterSpacing: -0.26,
                                                      height: 1,
                                                    ),
                                                    border: InputBorder.none,
                                                    contentPadding: EdgeInsets.zero,
                                                    isDense: true,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                                  size: 18,
                                                  color: Colors.grey[600],
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints: BoxConstraints(),
                                                onPressed: () {
                                                  setState(() {
                                                    _isPasswordVisible = !_isPasswordVisible;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (_passwordError != null) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            _passwordError!,
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFFD4183D),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w300,
                                              letterSpacing: -0.20,
                                              height: 1,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),

                                    const SizedBox(height: 15),

                                    // Confirm Password Field
                                    Text(
                                      'Confirm Password',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        letterSpacing: -0.26,
                                        height: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 36,
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: _isConfirmPasswordFocused ? 2 : 1,
                                              color: _confirmPasswordError != null
                                                  ? const Color(0xFFD4183D)
                                                  : (_isConfirmPasswordFocused ? const Color(0xFF5784EB) : Colors.black),
                                            ),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: _confirmPasswordController,
                                                  focusNode: _confirmPasswordFocusNode,
                                                  obscureText: !_isConfirmPasswordVisible,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w300,
                                                    letterSpacing: -0.26,
                                                    height: 1,
                                                  ),
                                                  decoration: InputDecoration(
                                                    hintText: 'Enter Your Password Again',
                                                    hintStyle: GoogleFonts.poppins(
                                                      color: Colors.black,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w300,
                                                      letterSpacing: -0.26,
                                                      height: 1,
                                                    ),
                                                    border: InputBorder.none,
                                                    contentPadding: EdgeInsets.zero,
                                                    isDense: true,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                                  size: 18,
                                                  color: Colors.grey[600],
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints: BoxConstraints(),
                                                onPressed: () {
                                                  setState(() {
                                                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (_confirmPasswordError != null) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            _confirmPasswordError!,
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFFD4183D),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w300,
                                              letterSpacing: -0.20,
                                              height: 1,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    // Terms checkbox
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: Checkbox(
                                            value: _agreeToTerms,
                                            onChanged: (value) {
                                              setState(() {
                                                _agreeToTerms = value ?? false;
                                              });
                                            },
                                            activeColor: const Color(0xFFFF4000),
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _agreeToTerms = !_agreeToTerms;
                                              });
                                            },
                                            child: Text(
                                              'I agree to the Terms of Service and Privacy Policy',
                                              style: GoogleFonts.poppins(
                                                color: Colors.black,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w300,
                                                letterSpacing: -0.22,
                                                height: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Create Account button - Responsive
                              PrimaryButton(
                                label: 'Create Account',
                                onPressed: _createAccountWithEmail,
                                enabled: _agreeToTerms && !_isLoading,
                                width: buttonWidth,
                                height: buttonHeight,
                              ),

                              const SizedBox(height: 20),

                              // Sign In link
                              SizedBox(
                                width: buttonWidth,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.signIn),
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Already have an account? ',
                                            style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: -0.24,
                                              height: 1,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Sign In',
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFFFBAE38),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              decoration: TextDecoration.underline,
                                              decorationColor: const Color(0xFFFBAE38),
                                              letterSpacing: -0.24,
                                              height: 1,
                                            ),
                                          ),
                                        ],
                                      ),
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
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }
}