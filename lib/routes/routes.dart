// import 'package:flutter/material.dart';
// import 'package:notesapp/pages/home_page.dart';
// import 'package:notesapp/pages/base_page.dart'; // Import BasePage dan halaman lainnya
//
// class AppRoutes {
//   static const String home = '/home';
//   static const String notes = '/notes';
//   static const String todo = '/todo';
//   static const String calendar = '/calendar';
//
//   static Map<String, WidgetBuilder> getRoutes() {
//     return {
//       home: (context) => const HomePage(),
//       notes: (context) => const NotesPage(),
//       todo: (context) => const TodoPage(),
//       calendar: (context) => const CalendarPage(),
//     };
//   }
// }
//
// // ============ MAIN.DART CONFIGURATION ============
// // Tambahkan ini di main.dart Anda:
//
// /*
// import 'package:flutter/material.dart';
// import 'package:notesapp/routes/app_routes.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Notes App',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         scaffoldBackgroundColor: Colors.white,