import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notesapp/features/calendar/data/services/event_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReminderCardWidget extends StatelessWidget {
  final String time;
  final String title;
  final String eventId;
  final DateTime eventTime;

  const ReminderCardWidget({
    super.key,
    required this.time,
    required this.title,
    required this.eventId,
    required this.eventTime,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showReminderOptions(context),
      child: Container(
        height: 64,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF5784EB),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 51.38,
              height: 48,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF5683EB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 24,
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      time,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF2D2D2D),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        height: 2.60,
                        letterSpacing: 0.50,
                      ),
                    ),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF2D2D2D),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.58,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Reminder Icon
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5784EB).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active,
                  color: Color(0xFF5784EB),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Show bottom sheet untuk pilih waktu reminder
  void _showReminderOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.alarm_add, color: Color(0xFF5784EB), size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Set Reminder',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Choose when you want to be reminded',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF6B6B6B),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildReminderOption(context, '5 minutes before', 5),
            _buildReminderOption(context, '10 minutes before', 10),
            _buildReminderOption(context, '15 minutes before', 15),
            _buildReminderOption(context, '30 minutes before', 30),
            _buildReminderOption(context, '1 hour before', 60),
            _buildReminderOption(context, '1 day before', 1440),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ✅ Build single reminder option
  Widget _buildReminderOption(BuildContext context, String label, int minutes) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF5784EB).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.notifications_outlined,
          color: Color(0xFF5784EB),
          size: 20,
        ),
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1A1A1A),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Color(0xFF6B6B6B),
      ),
      onTap: () {
        Navigator.pop(context); // Close bottom sheet
        _setReminder(context, minutes, label);
      },
    );
  }

  // ✅ Set reminder dengan waktu yang dipilih
  Future<void> _setReminder(BuildContext context, int minutes, String label) async {
    final messenger = ScaffoldMessenger.of(context);
    final eventService = EventService();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Please sign in to set reminders',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const CircularProgressIndicator(),
          ),
        ),
      );

      // Schedule reminder
      await eventService.scheduleEventReminder(
        userId: userId,
        eventId: eventId,
        eventTitle: title,
        eventTime: eventTime,
        minutesBefore: minutes,
      );

      // Close loading
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show success message
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF10B981),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Reminder Set! 🔔',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'You\'ll be reminded $label',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      // Close loading if error
      if (context.mounted) {
        Navigator.pop(context);
      }

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Failed to set reminder: ${e.toString()}',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}