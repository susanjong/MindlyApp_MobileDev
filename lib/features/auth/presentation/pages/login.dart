import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../config/routes/routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import 'package:notesapp/core/widgets/navigation/loading_overlay.dart';

class LoginAccountScreen extends StatefulWidget {
  const LoginAccountScreen({super.key});
  @override
  LoginAccountScreenState createState() => LoginAccountScreenState();
}

class LoginAccountScreenState extends State<LoginAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isLoading = false;

  // error messages
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();

    _emailFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isEmailFocused = _emailFocusNode.hasFocus;
        });
      }
    });

    _passwordFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isPasswordFocused = _passwordFocusNode.hasFocus;
        });
      }
    });

    // real-time validation
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  void _validateEmail() {
    if (mounted) {
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
  }

  void _validatePassword() {
    if (mounted) {
      setState(() {
        final value = _passwordController.text;
        if (value.isEmpty) {
          _passwordError = null;
        } else if (value.length < 6) {
          _passwordError = 'Password must be at least 6 characters';
        } else {
          _passwordError = null;
        }
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final userCredential = await AuthService.signInWithGoogle();

      if (userCredential == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back ${userCredential.user?.displayName ?? "User"}!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      }
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
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

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    if (mounted) {
      setState(() {
        if (_emailController.text.trim().isEmpty) {
          _emailError = 'Please enter your email';
        } else {
          _validateEmail();
        }

        if (_passwordController.text.isEmpty) {
          _passwordError = 'Please enter your password';
        } else {
          _validatePassword();
        }
      });
    }

    if (_emailError != null || _passwordError != null) {
      return;
    }

    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // login using authService
      final userCredential = await AuthService.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (userCredential != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      }
    } catch (e) {
      debugPrint('Login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, AppRoutes.signUp);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // image
                        Center(
                          child: SizedBox(
                            width: 180,
                            height: 150,
                            child: SvgPicture.asset(
                              'assets/images/Login_elemen.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // stack
                        Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 100,
                              margin: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                color: const Color(0x4CD9D9D9),
                                borderRadius: BorderRadius.circular(45),
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 30),
                                  child: Text(
                                    'Sign In Account',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                      height: 1,
                                      letterSpacing: -0.40,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 60),
                              padding: const EdgeInsets.fromLTRB(30, 30, 30, 50),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(35),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Sign in to continue your productivity journey',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: -0.30,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),

                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Google Sign In Button
                                        Container(
                                          width: double.infinity,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
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
                                                    width: 18,
                                                    height: 18,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return const Icon(Icons.g_mobiledata, color: Colors.blue, size: 18);
                                                    },
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    'Sign in with Google',
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
                                        Row(
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

                                        const SizedBox(height: 20),

                                        // email Field with error
                                        _buildEmailField(),

                                        const SizedBox(height: 20),

                                        // password Field with error
                                        _buildPasswordField(),

                                        const SizedBox(height: 15),

                                        // Forgot password
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pushReplacementNamed(context, AppRoutes.resetPassword);
                                            },
                                            child: Text(
                                              'Forgot Your Password?',
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFFFBAE38),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                height: 1,
                                                letterSpacing: -0.24,
                                                decoration: TextDecoration.underline,
                                                decorationColor: const Color(0xFFFBAE38),
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 30),

                                        // login button
                                        Center(
                                          child: PrimaryButton(
                                            label: ' Sign In Account',
                                            onPressed: _isLoading ? null : _handleLogin,
                                            enabled: !_isLoading,
                                            width: double.infinity,
                                            height: 38,
                                          ),
                                        ),

                                        const SizedBox(height: 20),
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
          ),

          // Loading overlay
          if (_isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }

  // email field with inline error
  Widget _buildEmailField() {
    final hasError = _emailError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.black,
            fontWeight: FontWeight.w500,
            height: 1,
            letterSpacing: -0.26,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: hasError ? 2 : (_isEmailFocused ? 2 : 1),
                color: hasError
                    ? const Color(0xFFD4183D)
                    : (_isEmailFocused ? const Color(0xFF5784EB) : Colors.black),
              ),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: TextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w300,
              height: 1,
              letterSpacing: -0.26,
            ),
            decoration: InputDecoration(
              hintText: 'Enter Your Email',
              hintStyle: GoogleFonts.poppins(
                color: Colors.black.withValues(alpha: 0.5),
                fontSize: 13,
                fontWeight: FontWeight.w300,
                height: 1,
                letterSpacing: -0.26,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
        ),

        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _emailError!,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFD4183D),
                letterSpacing: -0.22,
              ),
            ),
          ),
      ],
    );
  }

  // password field with inline error
  Widget _buildPasswordField() {
    final hasError = _passwordError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.black,
            fontWeight: FontWeight.w500,
            height: 1,
            letterSpacing: -0.26,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: hasError ? 2 : (_isPasswordFocused ? 2 : 1),
                color: hasError
                    ? const Color(0xFFD4183D)
                    : (_isPasswordFocused ? const Color(0xFF5784EB) : Colors.black),
              ),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: !_isPasswordVisible,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    height: 1,
                    letterSpacing: -0.26,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter Your Password',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.black.withValues(alpha: 0.5),
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      height: 1,
                      letterSpacing: -0.26,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[600],
                  size: 18,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _passwordError!,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFD4183D),
                letterSpacing: -0.22,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}