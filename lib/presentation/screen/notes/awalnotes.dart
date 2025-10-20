import 'package:flutter/material.dart';
import 'package:notesapp/presentation/widget/navbar.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes Page')),
      body: const Center(
        child: Text(
          'This is the Notes Page',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      // Navbar tetap bisa dipanggil kalau mau
      bottomNavigationBar: CustomNavBar(
        selectedIndex: 1,
        onItemTapped: (index) {
          // Optional: logika jika ingin update index lokal
        },
      ),
    );
  }
}
