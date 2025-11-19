import 'package:flutter/material.dart';
import 'package:notesapp/presentation/screen/entry/intro_app.dart';
import 'package:notesapp/presentation/screen/main_home/help_faq.dart';
import 'package:notesapp/presentation/screen/entry/splash_screen.dart';
import 'package:notesapp/presentation/screen/entry/login.dart';
import 'package:notesapp/presentation/screen/entry/resetpass.dart';
import 'package:notesapp/presentation/screen/entry/signup.dart';
import 'package:notesapp/presentation/screen/entry/forgotpass.dart';
import 'package:notesapp/presentation/screen/main_home/home.dart';
import 'package:notesapp/presentation/screen/main_home/profile.dart';
import 'package:notesapp/presentation/screen/main_home/about_info.dart';
import 'package:notesapp/presentation/screen/notes/notes_page.dart';
import 'package:notesapp/presentation/screen/todolist/awaltodo.dart';
import 'package:notesapp/presentation/screen/calendar/awalcalendar.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String introApp = '/intro_app';
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

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => LogoSplash());

      case introApp:
        return MaterialPageRoute(builder: (_) => WelcomeScreen());

      case signUp:
        return MaterialPageRoute(builder: (_) => SignUpScreen());

      case signIn:
        return MaterialPageRoute(builder: (_) => LoginAccountScreen());

      case home:
        return MaterialPageRoute(builder: (_) => HomePage());

      case resetPassword:
        return MaterialPageRoute(builder: (_) => ResetPasswordScreen());

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => ForgotPasswordScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => AccountProfilePage());

      case notes:
        return MaterialPageRoute(builder: (_) => NotesPage());

      case todo:
        return MaterialPageRoute(builder: (_) => TodoListPage());

      case calendar:
        return MaterialPageRoute(builder: (_) => CalendarPage());

      case helpFaq:
        return MaterialPageRoute(builder: (_) => HelpFaqScreen());

      case aboutUs:
        return MaterialPageRoute(builder: (_) => AboutPage());

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

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => LogoSplash(),
      introApp: (context) => WelcomeScreen(),
      signUp: (context) => SignUpScreen(),
      signIn: (context) => LoginAccountScreen(),
      home: (context) => HomePage(),
      resetPassword: (context) => ResetPasswordScreen(),
      forgotPassword: (context) => ForgotPasswordScreen(),
      profile: (context) => AccountProfilePage(),
      notes: (context) => NotesPage(),
      todo: (context) => TodoListPage(),
      calendar: (context) => CalendarPage(),
      helpFaq: (context) => HelpFaqScreen(),
      aboutUs: (context) => AboutPage(),
    };
  }
}
