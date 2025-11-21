import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notesapp/core/widgets/buttons/primary_button.dart';
import 'package:notesapp/config/routes/routes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  bool _isLoading = false;
  bool _isEmailFocused = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();

    _emailFocusNode.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus;
      });
    });

    _emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _validateEmail() {
    setState(() {
      final value = _emailController.text.trim();
      if (value.isEmpty) {
        _emailError = null;
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        _emailError = 'Please enter a valid email';
      } else {
        _emailError = null;
      }
    });
  }

  Future<void> _continue() async {
    // Validate on button press
    setState(() {
      if (_emailController.text.trim().isEmpty) {
        _emailError = 'Please enter your email';
      } else {
        _validateEmail();
      }
    });

    if (_emailError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB19CD9).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_read,
                    color: Color(0xFFB19CD9),
                    size: 45,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Check Your Email',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We have sent a password reset link to:',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFB19CD9),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Please check your email and click on the link to reset your password.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Back to Login',
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacementNamed(context, AppRoutes.resetPassword);
                    },
                    height: 45,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _continue(); // Resend email
                  },
                  child: Text(
                    'Resend Email',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFFB19CD9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      // Error handling (for future backend integration)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An unexpected error occurred. Please try again',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _emailError != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Back button
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.signIn);
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
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black54,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Title
                    Center(
                      child: Text(
                        'Reset Password',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          height: 1,
                          letterSpacing: -0.48,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    Center(
                      child: Text(
                        'Enter your email account to reset password',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 1,
                          letterSpacing: -0.30,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // SVG Image
                    Center(
                      child: SizedBox(
                        width: 230,
                        height: 200,
                        child: SvgPicture.asset(
                          'assets/images/resetpass_elemen.svg',
                          fit: BoxFit.contain,
                          placeholderBuilder: (BuildContext context) => Container(
                            padding: const EdgeInsets.all(30.0),
                            child: const CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Email Field with error
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1,
                              letterSpacing: -0.26,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 36,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: hasError ? 2 : (_isEmailFocused ? 2 : 1),
                                color: hasError
                                    ? const Color(0xFFD4183D)
                                    : (_isEmailFocused ? const Color(0xFF5784EB) : Colors.black),
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: TextField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                letterSpacing: -0.26,
                                height: 1,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter Your Email',
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.black.withOpacity(0.5),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: -0.26,
                                  height: 1,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                isDense: true,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          // Error message
                          if (hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _emailError!,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFFD4183D),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.22,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Continue Button
                    PrimaryButton(
                      label: 'Continue',
                      onPressed: _isLoading ? null : _continue,
                      width: double.infinity,
                      height: 38,
                      showArrow: true,
                      enabled: !_isLoading,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sending reset link...',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}