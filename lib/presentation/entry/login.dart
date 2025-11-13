// File: screens/login.dart
import 'package:flutter/material.dart';
import 'package:notesapp/widgets/button.dart';

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

  @override
  void initState() {
    super.initState();

    // Listen to email field focus changes
    _emailFocusNode.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus;
      });
    });

    // Listen to password field focus changes
    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          SizedBox(height: statusBarHeight),

          // Back button - Navigasi kembali ke signup
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
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
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Gambar ilustrasi
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

                  // Stack untuk kotak abu-abu dan white container
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // Kotak abu-abu
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
                              'Login Account',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 24,
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
                              'Sign in to continue your productivity journey',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),

                            // Form Section
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Email Field
                                  const Text(
                                    'Email',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: _isEmailFocused ? Colors.purple : Colors.grey[300]!,
                                        width: _isEmailFocused ? 2.0 : 1.5,
                                      ),
                                    ),
                                    child: TextFormField(
                                      controller: _emailController,
                                      focusNode: _emailFocusNode,
                                      keyboardType: TextInputType.emailAddress,
                                      style: const TextStyle(fontFamily: 'Poppins'),
                                      decoration: InputDecoration(
                                        hintText: 'Enter Your Email',
                                        hintStyle: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.grey[500],
                                          fontSize: 15,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 18),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Password Field
                                  const Text(
                                    'Password',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: _isPasswordFocused ? Colors.purple : Colors.grey[300]!,
                                        width: _isPasswordFocused ? 2.0 : 1.5,
                                      ),
                                    ),
                                    child: TextFormField(
                                      controller: _passwordController,
                                      focusNode: _passwordFocusNode,
                                      obscureText: !_isPasswordVisible,
                                      style: const TextStyle(fontFamily: 'Poppins'),
                                      decoration: InputDecoration(
                                        hintText: 'Enter Your Password',
                                        hintStyle: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.grey[500],
                                          fontSize: 15,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                          borderSide: BorderSide.none,
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
                                        return null;
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  // Forgot Password Link
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context, '/forgotpass');
                                      },
                                      child: Text(
                                        'Forgot Your Password?',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.purple,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 30),

                                  // Login Button pakai widget button yang primary tu
                                  Center(
                                    child: PrimaryButton(
                                      label: 'Login Account',
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          // Navigasi ke home setelah login berhasil
                                          Navigator.pushNamed(context, '/home');
                                        }
                                      },
                                      width: double.infinity,
                                      height: 55,
                                    ),
                                  ),

                                  const SizedBox(height: 25),
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
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}