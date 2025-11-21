import 'package:flutter/material.dart';
import 'package:notesapp/core/widgets/navigation/navbar.dart'; // pastikan path import benar

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Page'),
      ),
      body: const Center(
        child: Text(
          'This is the Calendar Page',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
