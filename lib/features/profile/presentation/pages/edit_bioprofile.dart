import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notesapp/core/widgets/buttons/primary_button.dart';

class EditAccountInformationScreen extends StatefulWidget {
  const EditAccountInformationScreen({super.key});

  @override
  State<EditAccountInformationScreen> createState() => _EditAccountInformationScreenState();
}

class _EditAccountInformationScreenState extends State<EditAccountInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // TODO: Replace with actual name from db
    _firstNameController.text = 'Susan';
    _lastNameController.text = 'Jong';
    _bioController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // make a responsive screen
    final double inputWidth = screenWidth > 600 ? 400 : 340;
    final double buttonWidth = screenWidth > 600 ? 400 : 340;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          padding: const EdgeInsets.only(left: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Account Information',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 1,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 49),

                // profile picture
                Container(
                  width: 60,
                  height: 60,
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    image: const DecorationImage(
                      image: NetworkImage("https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop"),
                      // TODO: Replace with actual image
                      fit: BoxFit.cover,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),

                const SizedBox(height: 17),

                Text(
                  'Susan Jong',   // TODO: Replace with actual name from db
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'susanjong05@gmail.com', // TODO: Replace with actual email from db
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6A6E76),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),

                const SizedBox(height: 44),

                // first name input
                Center(
                  child: Container(
                    width: inputWidth,
                    height: 40,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFFFCFC),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: TextFormField(
                      controller: _firstNameController,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                      decoration: InputDecoration(
                        hintText: "What's your first name?",
                        hintStyle: GoogleFonts.poppins(
                          color: const Color(0xFF6A6E76),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 14),
                        isDense: true,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // last name input
                Center(
                  child: Container(
                    width: inputWidth,
                    height: 40,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFFFCFC),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: TextFormField(
                      controller: _lastNameController,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                      decoration: InputDecoration(
                        hintText: "And your last name?",
                        hintStyle: GoogleFonts.poppins(
                          color: const Color(0xFF6A6E76),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 14),
                        isDense: true,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // bio input
                Center(
                  child: Container(
                    width: inputWidth,
                    height: 40,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFFFCFC),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: TextFormField(
                      controller: _bioController,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                      decoration: InputDecoration(
                        hintText: "Edit bio in here.....",
                        hintStyle: GoogleFonts.poppins(
                          color: const Color(0xFF6A6E76),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 14),
                        isDense: true,
                        suffixIcon: const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.edit_outlined,
                            color: Colors.black,
                            size: 15,
                          ),
                        ),
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 30,
                          minHeight: 40,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                // save button
                Center(
                  child: PrimaryButton(
                    label: 'Save',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // TODO: Save logic here
                        Navigator.pop(context);
                      }
                    },
                    enabled: true,
                    showArrow: true,
                    width: buttonWidth,
                    height: 38,
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}