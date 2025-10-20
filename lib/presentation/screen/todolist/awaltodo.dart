import 'package:flutter/material.dart';
import 'package:notesapp/presentation/widget/navbar.dart'; // pastikan path import benar

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-do List Page'),
      ),
      body: const Center(
        child: Text(
          'This is the To-do List Page',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
