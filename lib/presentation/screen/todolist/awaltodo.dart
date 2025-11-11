
import 'package:flutter/material.dart';
import 'package:notesapp/widgets/custom_navbar_widget.dart'; // Menggunakan widget navbar yang sudah dipisah

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/notes');
        break;
      case 2:
        // No action needed, already on this page
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/calendar');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: const Center(
        child: Text('Todo List Page'),
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: 2, // Index untuk Todo
        onItemTapped: _navigateToPage,
      ),
    );
  }
}
