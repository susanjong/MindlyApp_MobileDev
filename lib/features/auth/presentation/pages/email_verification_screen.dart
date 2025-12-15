import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/routes/routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/buttons/primary_button.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  EmailVerificationScreenState createState() => EmailVerificationScreenState();
}

class EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isLoading = false;
  bool _isCheckingVerification = false;
  bool _isHovering = true;
  Timer? _timer;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    _startAutoCheck();
  }

  void _startAutoCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      await _checkEmailVerified(showMessage: false);
    });
  }

  Future<void> _checkEmailVerified({bool showMessage = true}) async {
    if (_isCheckingVerification) return;

    setState(() {
      _isCheckingVerification = true;
    });

    try {
      final isVerified = await AuthService.checkEmailVerified();

      if (isVerified && mounted) {
        _timer?.cancel();

        if (showMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Email verified successfully! Redirecting...',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.home,
                (route) => false,
          );
        }
      } else if (showMessage && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Email not verified yet. Please check your inbox.',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error checking verification: $e');
      if (showMessage && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingVerification = false;
        });
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_isLoading || _resendCountdown > 0) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.sendEmailVerification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Verification email sent! Please check your inbox.',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        setState(() {
          _resendCountdown = 60;
        });

        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }

          setState(() {
            _resendCountdown--;
          });

          if (_resendCountdown <= 0) {
            timer.cancel();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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

  Future<void> _signOut() async {
    try {
      await AuthService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.signUp);
      }
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = AuthService.getCurrentUserEmail() ?? '';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Email icon illustration
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4000).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_outlined,
                      size: 80,
                      color: Color(0xFFFF4000),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Title - 28sp Poppins Bold
                  Text(
                    'Verify Your Email',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: -0.56,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // description - 15sp Poppins Regular
                  Text(
                    'We\'ve sent a verification link to:',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                      letterSpacing: -0.30,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  // Email address - 14sp Poppins SemiBold
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      userEmail,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF4000),
                        letterSpacing: -0.28,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // instructions - 13sp Poppins Regular
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5784EB).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFF5784EB).withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFF5784EB),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Please check your email and click the verification link. You will be redirected automatically.',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF5784EB),
                                  letterSpacing: -0.26,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.folder_outlined,
                              color: Color(0xFF5784EB),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Don\'t forget to check your spam/junk folder if you don\'t see the email.',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF5784EB),
                                  letterSpacing: -0.26,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Auto-checking indicator - 13sp Poppins Medium
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Waiting for email verification...',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.green.shade800,
                              letterSpacing: -0.26,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // resend button - Primary Button with blue #5784EB
                  PrimaryButton(
                    label: _resendCountdown > 0
                        ? 'Resend in ${_resendCountdown}s'
                        : 'Resend Verification Email',
                    onPressed: _resendCountdown > 0 ? null : _resendVerificationEmail,
                    enabled: _resendCountdown == 0 && !_isLoading,
                    width: double.infinity,
                    height: 48,
                    backgroundColor: const Color(0xFFD732A8),
                  ),

                  const SizedBox(height: 15),

                  // check manually button
                  MouseRegion(
                    onEnter: (_) => setState(() => _isHovering = true),
                    onExit: (_) => setState(() => _isHovering = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _isHovering
                            ? const Color(0xFF5784EB).withValues(alpha: 0.8)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF5784EB),
                          width: 2,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isLoading ? null : () => _checkEmailVerified(showMessage: true),
                          borderRadius: BorderRadius.circular(10),
                          child: Center(
                            child: Text(
                              'I\'ve Verified My Email',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _isHovering
                                    ? Colors.white
                                    : const Color(0xFFFF4000),
                                letterSpacing: -0.30,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // sign out link - 14sp Poppins Medium
                  TextButton(
                    onPressed: _signOut,
                    child: Text(
                      'Sign Out',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                        letterSpacing: -0.28,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}