import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notesapp/core/widgets/buttons/primary_button.dart';
import 'package:notesapp/config/routes/routes.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulation API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reset password link has been sent to your email!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.forgotPassword);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: 393,
          height: 852,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              // back button
              Positioned(
                left: 16,
                top: 16,
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

              // title
              Positioned(
                left: 111,
                top: 80,
                child: Text(
                  'Reset Password ',
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

              // subtitle
              Positioned(
                left: 25,
                top: 140,
                child: SizedBox(
                  width: 358,
                  height: 19,
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
              ),

             //img svg
              Positioned(
                left: 81.43,
                top: 200,
                child: SizedBox(
                  width: 230.14,
                  height: 200,
                  child: SvgPicture.asset(
                    'assets/images/resetpass_elemen.svg',
                    fit: BoxFit.contain,
                    placeholderBuilder: (BuildContext context) => Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: const CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),

              // email label
              Positioned(
                left: 48,
                top: 450,
                child: Text(
                  'Email',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1,
                    letterSpacing: -0.26,
                  ),
                ),
              ),

              // email input field
              Positioned(
                left: 48,
                top: 471,
                child: Form(
                  key: _formKey,
                  child: SizedBox(
                    width: 312,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            validator: _validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              letterSpacing: -0.26,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter Your Email',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                letterSpacing: -0.26,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                              isDense: true,
                              errorStyle: const TextStyle(height: 0, fontSize: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: Colors.black, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: Colors.black, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: Color(0xFF5784EB), width: 1.5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: Colors.red, width: 1),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: Colors.red, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                        // error message in down field
                        if (_formKey.currentState != null)
                          ValueListenableBuilder(
                            valueListenable: _emailController,
                            builder: (context, value, child) {
                              final error = _validateEmail(_emailController.text);
                              if (error != null && _emailController.text.isNotEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4, left: 2),
                                  child: Text(
                                    error,
                                    style: GoogleFonts.poppins(
                                      color: Colors.red,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // continue button - using widget primary button
              Positioned(
                left: 48,
                top: 560,
                child: PrimaryButton(
                  label: 'Continue',
                  onPressed: _isLoading ? null : _continue,
                  width: 312,
                  height: 38,
                  showArrow: true,
                  enabled: !_isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}