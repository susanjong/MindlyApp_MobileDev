import 'package:flutter/material.dart';
import 'package:notesapp/widgets/button.dart';
import 'package:notesapp/routes/routes.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginAccountScreen extends StatefulWidget {
  @override
  _LoginAccountScreenState createState() => _LoginAccountScreenState();
}

class _LoginAccountScreenState extends State<LoginAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;

  // error messages
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();

    _emailFocusNode.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus;
      });
    });

    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
    });

    // real-time validation
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  void _validateEmail() {
    setState(() {
      final value = _emailController.text.trim();
      if (value.isEmpty) {
        _emailError = null; // Don't show error while typing
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        _emailError = 'Please enter a valid email';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword() {
    setState(() {
      final value = _passwordController.text;
      if (value.isEmpty) {
        _passwordError = null; // Don't show error while typing
      } else if (value.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = null;
      }
    });
  }

  void _handleLogin() {
    // validate on button press
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

    if (_emailError != null || _passwordError != null) {
      return;
    }

    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      return;
    }

    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.2),
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
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Image
                    Center(
                      child: Container(
                        width: 250,
                        height: 200,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/sigin_elemen.png"),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Stack
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
                                'Login Account',
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
                                  fontSize: 16,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 40),

                              Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                          Navigator.pushReplacementNamed(context, AppRoutes.forgotPassword);
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

                                    // Login button
                                    Center(
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          return PrimaryButton(
                                            label: 'Login Account',
                                            onPressed: _handleLogin,
                                            width: constraints.maxWidth,
                                            height: 38,
                                          );
                                        },
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
        // error message in down field text
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