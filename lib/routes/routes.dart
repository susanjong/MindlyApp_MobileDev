import 'package:flutter/material.dart';
import 'package:notesapp/presentation/screen/main_home/help_faq.dart';
import 'package:notesapp/presentation/screen/splash_screen.dart';
import 'package:notesapp/presentation/entry/login.dart';
import 'package:notesapp/presentation/entry/resetpass.dart';
import 'package:notesapp/presentation/entry/signup.dart';
import 'package:notesapp/presentation/entry/forgotpass.dart';
import 'package:notesapp/presentation/screen/main_home/home.dart';
import 'package:notesapp/presentation/screen/main_home/profile.dart';
import 'package:notesapp/presentation/screen/main_home/about_info.dart';
import 'package:notesapp/presentation/screen/notes/awalnotes.dart';
import 'package:notesapp/presentation/screen/todolist/awaltodo.dart';
import 'package:notesapp/presentation/screen/calendar/awalcalendar.dart';

class AppRoutes {
  // make ur route name
  static const String splash = '/';
  static const String signUp = '/sign_up';
  static const String signIn = '/sign_in';
  static const String home = '/home';
  static const String resetPassword = '/reset_password';
  static const String forgotPassword = '/forgot_password';
  static const String profile = '/profile';
  static const String notes = '/notes';
  static const String todo = '/todo';
  static const String calendar = '/calendar';
  static const String helpFaq = '/help_faq';
  static const String aboutUs = '/about_info';

  // generator for route
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const LogoSplash());

      case signUp:
        return MaterialPageRoute(builder: (_) => SignUpScreen());

      case signIn:
        return MaterialPageRoute(builder: (_) => LoginAccountScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case resetPassword:
        return MaterialPageRoute(builder: (_) => ResetPasswordScreen());

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => ForgotPasswordScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const AccountProfilePage());

      case notes:
        return MaterialPageRoute(builder: (_) => const NotesPage());

      case todo:
        return MaterialPageRoute(builder: (_) => const TodoListPage());

      case calendar:
        return MaterialPageRoute(builder: (_) => const CalendarPage());

      case aboutUs:
        return MaterialPageRoute(builder: (_) => const AboutPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                'Route ${settings.name} not found',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        );
    }
  }

  // route map
  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const LogoSplash(),
      signUp: (context) => SignUpScreen(),
      signIn: (context) => LoginAccountScreen(),
      home: (context) => const HomePage(),
      resetPassword: (context) => ResetPasswordScreen(),
      forgotPassword: (context) => ForgotPasswordScreen(),
      profile: (context) => const AccountProfilePage(),
      notes: (context) => const NotesPage(),
      todo: (context) => const TodoListPage(),
      calendar: (context) => const CalendarPage(),
      aboutUs: (context) => const AboutPage(),
      helpFaq: (context) => const HelpFaqScreen(),
    };
  }
}