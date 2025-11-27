import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/forgotpass.dart';
import '../../features/auth/presentation/pages/intro_app.dart';
import '../../features/auth/presentation/pages/login.dart';
import '../../features/auth/presentation/pages/resetpass.dart';
import '../../features/auth/presentation/pages/signup.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/home/presentation/pages/home.dart';
import '../../features/notes/presentation/pages/note_editor_page.dart';
import '../../features/notes/presentation/pages/notes_main_page.dart';
import '../../features/to_do_list/presentation/pages/mainTodo.dart';
import '../../features/calendar/presentation/pages/awalcalendar.dart';
import '../../features/profile/presentation/pages/about_info.dart';
import '../../features/profile/presentation/pages/help_faq.dart';
import '../../features/profile/presentation/pages/profile.dart';

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
  static const String noteEditor = '/note-editor';
  static const String todo = '/todo';
  static const String calendar = '/calendar';
  static const String helpFaq = '/help_faq';
  static const String aboutUs = '/about_info';
  static const String termsOfService = '/terms-of-service';
  static const String PrivacyPolicy = '/privacy-policy';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const LogoSplash());
      case introApp:
        return _buildRoute(const WelcomeScreen());
      case signUp:
        return _buildRoute(const SignUpScreen());
      case signIn:
        return _buildRoute(const LoginAccountScreen());
      case home:
        return _buildRoute(const HomePage());
      case resetPassword:
        return _buildRoute(const ResetPasswordScreen());
      case AppRoutes.termsOfService:
        return MaterialPageRoute(builder: (_) => const TermsOfServiceScreen());
      case AppRoutes.PrivacyPolicy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());
      case forgotPassword:
        return _buildRoute(const ForgotPasswordScreen());
      case profile:
        return _buildRoute(const AccountProfilePage());
      case notes:
        return _buildRoute(const NotesMainPage());

      case noteEditor:
        final noteId = settings.arguments as String?;
        return _buildRoute(NoteEditorPage(noteId: noteId));
      case todo:
        return _buildRoute(const MainTodoScreen());
      case calendar:
        return _buildRoute(const CalendarPage());
      case helpFaq:
        return _buildRoute(const HelpFaqScreen());
      case aboutUs:
        return _buildRoute(const AboutPage());

    // Default - 404
      default:
        return _buildRoute(_NotFoundPage(routeName: settings.name));
    }
  }

  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}

/// 404 Not Found Page
class _NotFoundPage extends StatelessWidget {
  final String? routeName;

  const _NotFoundPage({this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Route "$routeName" not found',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}