import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/routes/routes.dart';
import '../widgets/faq_item.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // get padding for safe areas (notch, status bar, etc)
    final EdgeInsets safeAreaPadding = MediaQuery.of(context).padding;
    final double screenWidth = MediaQuery.of(context).size.width;

    // responsive padding dan font sizes
    final double horizontalPadding = screenWidth > 600 ? 32 : 16;
    final double titleFontSize = screenWidth > 600 ? 28 : 24;
    final double sectionFontSize = screenWidth > 600 ? 20 : 17;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar with safe area
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
                    // Page title
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

                    // all about questions section
                    FaqSection(
                      title: 'ACCOUNT & SECURITY',
                      children: [
                        FaqItem(
                          question: 'How to reset my password?',
                          answer: 'To reset your password:\n'
                              '1. Tap the Profile icon at the top, next to the notification (bell) icon \n'
                              '2. Select the "Security" section \n'
                              '3. Choose "Reset Password" \n'
                              '4. When the confirmation alert appears, tap "Yes" to proceed \n'
                              '5. Enter your new password and save the changes',
                        ),
                        FaqItem(
                          question: 'How to delete my account?',
                          answer: 'To delete your account:\n'
                              '1. Tap the Profile icon at the top, next to the notification (bell) icon \n'
                              '2. Select the "Danger Zone" section\n'
                              '3. Click "Delete Account"\n'
                              '4. Confirm your decision\n'
                              '5. Enter your new password and save the changes \n'
                              'Note: This action cannot be undone and all your data will be permanently deleted.',
                        ),
                        FaqItem(
                          question: "Why can't I log in?",
                          answer: 'Common reasons for login issues:\n'
                              '• Incorrect email or password\n'
                              '• Account has been deactivated\n'
                              '• Network connection problems\n'
                              '• App needs to be updated\n'
                              'Try resetting your password or contact support if the issue persists.',
                        ),
                      ],
                    ),

                    FaqSection(
                      title: 'APP FEATURE',
                      children: [
                        FaqItem(
                          question: 'How to add new tasks?',
                          answer: 'To add a new task:\n'
                              '1. Open the To-Do List section\n'
                              '2. Click the "+" button at the bottom\n'
                              '3. Enter task title and description\n'
                              '4. Set due date and priority (optional)\n'
                              '5. Click "Save" to create the task',
                        ),
                        // FaqItem(
                        //   question: 'How to use OCR feature in your app?',
                        //   answer: 'To use OCR (Optical Character Recognition):\n'
                        //       '1. Open the Notes section\n'
                        //       '2. Click "Scan Text" or camera icon\n'
                        //       '3. Point your camera at the text you want to capture\n'
                        //       '4. Take a photo\n'
                        //       '5. The app will automatically extract and convert the text\n'
                        //       '6. Edit and save the extracted text',
                        // ),
                      ],
                    ),

                    FaqSection(
                      title: 'TECHNICAL SUPPORT',
                      children: [
                        FaqItem(
                          question: 'App is running slowly, what should I do?',
                          answer: 'Try these solutions:\n'
                              '• Close other apps running in the background\n'
                              '• Clear app cache in settings\n'
                              '• Check your internet connection\n'
                              '• Restart your device\n'
                              '• Update the app to the latest version\n'
                              '• Free up storage space on your device',
                        ),
                        FaqItem(
                          question: 'How to contact customer service?',
                          answer: 'You can reach our customer service through:\n'
                              '• Email: mindlyapp@gmail.com\n'
                              '• Phone: +1-800-123-4567 (Mon-Fri, 9AM-6PM)\n'
                              '• Social media: @mindlyapp on Twitter and Facebook\n\n'
                              'We typically respond within 24 hours.',
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