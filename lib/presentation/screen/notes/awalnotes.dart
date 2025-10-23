import 'package:flutter/material.dart';
import 'package:notesapp/widgets/navbar.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notes Page'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'This is the Notes Page',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),

      // navbar dengan struktur sama seperti di HomePage (copy aja bagian ini)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: CustomNavBar(
            selectedIndex: 1, // Index 1 untuk Notes
            onItemTapped: (index) {
            },
          ),
        ),
      ), //sampai sini nanti copynya
    );
  }
}