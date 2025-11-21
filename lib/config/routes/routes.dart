import 'package:flutter/material.dart';
import 'package:notesapp/features/auth/presentation/pages/intro_app.dart';
import 'package:notesapp/features/profile/presentation/pages/help_faq.dart';
import 'package:notesapp/features/auth/presentation/pages/splash_screen.dart';
import 'package:notesapp/features/auth/presentation/pages/login.dart';
import 'package:notesapp/features/auth/presentation/pages/resetpass.dart';
import 'package:notesapp/features/auth/presentation/pages/signup.dart';
import 'package:notesapp/features/auth/presentation/pages/forgotpass.dart';
import 'package:notesapp/features/home/presentation/pages/home.dart';
import 'package:notesapp/features/profile/presentation/pages/profile.dart';
import 'package:notesapp/features/profile/presentation/pages/about_info.dart';
import 'package:notesapp/features/notes/presentation/pages/notes_page.dart';
import 'package:notesapp/features/to_do_list/presentation/pages/awaltodo.dart';
import 'package:notesapp/features/calendar/presentation/pages/awalcalendar.dart';

import '../../features/notes/presentation/pages/add_note.dart';

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
  static const String addNote = '/add-note';
  static const String editNote = '/edit-note';
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

      case addNote:
        return MaterialPageRoute(builder: (_) => AddEditNotePage());

      case editNote:
        final noteId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => AddEditNotePage(noteId: noteId),
        );

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