import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/routes/routes.dart';
import '../widgets/faq_item.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // responsive padding
    final double horizontalPadding = screenWidth > 600 ? 32 : 16;
    final double titleFontSize = screenWidth > 600 ? 28 : 24;
    final double sectionFontSize = screenWidth > 600 ? 20 : 17;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // custom appbar
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0x9B999191),
                    width: 1,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black54),
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Help & FAQ',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24, left: 4),
                      child: Text(
                        'Frequently Asked Questions',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: sectionFontSize,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    FaqSection(
                      title: 'account & security',
                      children: [
                        FaqItem(
                          question: 'how to reset my password?',
                          answer: 'to reset your password:\n'
                              '1. tap the profile icon at the top, next to the notification bell icon \n'
                              '2. select the "security" section \n'
                              '3. choose "reset password" \n'
                              '4. when the confirmation alert appears, tap "yes" to proceed \n'
                              '5. enter your new password and save the changes',
                        ),
                        FaqItem(
                          question: 'how to delete my account?',
                          answer: 'to delete your account:\n'
                              '1. tap the profile icon at the top, next to the notification bell icon \n'
                              '2. select the "danger zone" section\n'
                              '3. click "delete account"\n'
                              '4. confirm your decision\n'
                              '5. enter your new password and save the changes \n'
                              'note: this action cannot be undone and all your data will be permanently deleted.',
                        ),
                        FaqItem(
                          question: "why can't i log in?",
                          answer: 'common reasons for login issues:\n'
                              '• incorrect email or password\n'
                              '• account has been deactivated\n'
                              '• network connection problems\n'
                              '• app needs to be updated\n'
                              'try resetting your password or contact support if the issue persists.',
                        ),
                      ],
                    ),

                    FaqSection(
                      title: 'app feature',
                      children: [
                        FaqItem(
                          question: 'how to add new tasks?',
                          answer: 'to add a new task:\n'
                              '1. open the to-do list section\n'
                              '2. click the "+" button at the bottom\n'
                              '3. enter task title and description\n'
                              '4. set due date and priority optional\n'
                              '5. click "save" to create the task',
                        ),
                      ],
                    ),

                    FaqSection(
                      title: 'technical support',
                      children: [
                        FaqItem(
                          question: 'app is running slowly, what should i do?',
                          answer: 'try these solutions:\n'
                              '• close other apps running in the background\n'
                              '• clear app cache in settings\n'
                              '• check your internet connection\n'
                              '• restart your device\n'
                              '• update the app to the latest version\n'
                              '• free up storage space on your device',
                        ),
                        FaqItem(
                          question: 'how to contact customer service?',
                          answer: 'you can reach our customer service through:\n'
                              '• email: mindlyapp@gmail.com\n'
                              '• phone: +1-800-123-4567 mon-fri, 9am-6pm\n'
                              '• social media: @mindlyapp on twitter and facebook\n\n'
                              'we typically respond within 24 hours.',
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}