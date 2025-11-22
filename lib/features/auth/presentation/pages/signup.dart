import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../config/routes/routes.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import './../../../../core/services/auth_service.dart';
import './../../../../core/widgets/navigation/loading_overlay.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _agreeToTerms = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isNameFocused = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isConfirmPasswordFocused = false;

  // error messages
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _termsError;

  @override
  void initState() {
    super.initState();

    _nameFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isNameFocused = _nameFocusNode.hasFocus;
        });
      }
    });

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

    _confirmPasswordFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isConfirmPasswordFocused = _confirmPasswordFocusNode.hasFocus;
        });
      }
    });

    // real-time validation
    _nameController.addListener(_validateName);
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  void _validateName() {
    if (mounted) {
      setState(() {
        final value = _nameController.text.trim();
        if (value.isEmpty) {
          _nameError = null;
        } else if (value.length < 3) {
          _nameError = 'Name must be at least 3 characters';
        } else {
          _nameError = null;
        }
      });
    }
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
        } else if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
          _passwordError = 'Password must contain uppercase, lowercase, and numbers';
        } else {
          _passwordError = null;
        }
      });
    }
    _validateConfirmPassword();
  }

  void _validateConfirmPassword() {
    if (mounted) {
      setState(() {
        final value = _confirmPasswordController.text;
        if (value.isEmpty) {
          _confirmPasswordError = null;
        } else if (value != _passwordController.text) {
          _confirmPasswordError = 'Password does not match';
        } else {
          _confirmPasswordError = null;
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
            content: Text('Welcome ${userCredential.user?.displayName ?? "User"}!'),
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

  Future<void> _createAccountWithEmail() async {
    if (_isLoading) return;

    // validate all fields
    if (mounted) {
      setState(() {
        if (_nameController.text.trim().isEmpty) {
          _nameError = 'Please enter your name';
        } else {
          _validateName();
        }

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

        if (_confirmPasswordController.text.isEmpty) {
          _confirmPasswordError = 'Please confirm your password';
        } else {
          _validateConfirmPassword();
        }

        if (!_agreeToTerms) {
          _termsError = 'Please agree to the Terms of Service and Privacy Policy';
        } else {
          _termsError = null;
        }
      });
    }

    // check if any errors exist
    if (_nameError != null || _emailError != null || _passwordError != null ||
        _confirmPasswordError != null || _termsError != null) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // Create account used AuthService
      final userCredential = await AuthService.createAccountWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text,
        displayName: _nameController.text.trim(),
      );

      if (userCredential != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created successfully! '),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      }
    } catch (e) {
      debugPrint('Create account error: $e');
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // header SVG image
                  Center(
                    child: SizedBox(
                      width: 213,
                      height: 165,
                      child: SvgPicture.asset(
                        'assets/images/SignUp_elemen.svg',
                        fit: BoxFit.contain,
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
                                fontSize: 20,
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
                        margin: const EdgeInsets.only(top: 51),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
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
                            Text(
                              'Start your productivity journey today!',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                letterSpacing: -0.30,
                                height: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),

                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // google Sign In Button
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

                                  const SizedBox(height: 15),

                                  // NAME Field (BARU)
                                  _buildTextField(
                                    label: 'Full Name',
                                    controller: _nameController,
                                    focusNode: _nameFocusNode,
                                    isFocused: _isNameFocused,
                                    hintText: 'Enter Your Full Name',
                                    keyboardType: TextInputType.name,
                                    errorText: _nameError,
                                  ),

                                  const SizedBox(height: 15),

                                  // email Field
                                  _buildTextField(
                                    label: 'Email',
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    isFocused: _isEmailFocused,
                                    hintText: 'Enter Your Email',
                                    keyboardType: TextInputType.emailAddress,
                                    errorText: _emailError,
                                  ),

                                  const SizedBox(height: 15),

                                  // password field
                                  _buildPasswordField(
                                    label: 'Password',
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    isFocused: _isPasswordFocused,
                                    isVisible: _isPasswordVisible,
                                    onToggleVisibility: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                    errorText: _passwordError,
                                  ),

                                  const SizedBox(height: 15),

                                  // confirm Password Field
                                  _buildPasswordField(
                                    label: 'Confirm Password',
                                    controller: _confirmPasswordController,
                                    focusNode: _confirmPasswordFocusNode,
                                    isFocused: _isConfirmPasswordFocused,
                                    isVisible: _isConfirmPasswordVisible,
                                    hintText: 'Enter Your Password Again',
                                    onToggleVisibility: () {
                                      setState(() {
                                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                      });
                                    },
                                    errorText: _confirmPasswordError,
                                  ),

                                  const SizedBox(height: 20),

                                  // terms checkbox
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
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
                                                  if (_agreeToTerms) {
                                                    _termsError = null;
                                                  }
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
                                                  if (_agreeToTerms) {
                                                    _termsError = null;
                                                  }
                                                });
                                              },
                                              child: Text(
                                                'I agree to the Terms of Service and Privacy Policy',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.black,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w300,
                                                  letterSpacing: -0.22,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      if (_termsError != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4, left: 26),
                                          child: Text(
                                            _termsError!,
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.red,
                                              letterSpacing: -0.22,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 30),

                                  // create Account button
                                  Center(
                                    child: PrimaryButton(
                                      label: 'Create Account',
                                      onPressed: _createAccountWithEmail,
                                      enabled: _agreeToTerms && !_isLoading,
                                      width: double.infinity,
                                      height: 38,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // sign In link
                                  Align(
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

          if (_isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String hintText,
    TextInputType? keyboardType,
    String? errorText,
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            letterSpacing: -0.26,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
          decoration: BoxDecoration(
            border: Border.all(
              width: hasError ? 2 : (isFocused ? 2 : 1),
              color: hasError ? const Color(0xFFD4183D) : (isFocused ? const Color(0xFF5784EB) : Colors.black),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w300,
              letterSpacing: -0.26,
              height: 1,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(
                color: Colors.black.withValues(alpha: 0.5),
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
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText,
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String hintText = 'Enter Your Password',
    String? errorText,
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            letterSpacing: -0.26,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
          decoration: BoxDecoration(
            border: Border.all(
              width: hasError ? 2 : (isFocused ? 2 : 1),
              color: hasError ? const Color(0xFFD4183D) : (isFocused ? const Color(0xFF5784EB) : Colors.black),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  obscureText: !isVisible,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -0.26,
                    height: 1,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.black.withValues(alpha: 0.5),
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
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  size: 18,
                  color: Colors.grey[600],
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onToggleVisibility,
              ),
            ],
          ),
        ),

        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText,
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }
}