import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../features/calendar/data/services/category_service.dart';
import '../../../../features/calendar/data/services/event_service.dart';
import '../../data/models/event_model.dart';
import 'add_event.dart';
import 'delete_repeated_event.dart';
import '../../../../core/widgets/dialog/alert_dialog.dart';

class EventDetailSheet extends StatelessWidget {
  final Event event;
  final Category? category;

  const EventDetailSheet({
    super.key,
    required this.event,
    this.category,
  });

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = category != null
        ? _getColorFromHex(category!.color)
        : const Color(0xFF5683EB);
    final categoryName = category?.name ?? 'General';

    // Hitung tinggi maksimal agar tidak menutupi seluruh layar (opsional, tapi bagus untuk UX)
    final double maxSheetHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight), // Batasi tinggi maksimal
      decoration: const BoxDecoration(
        color: Color(0xFFEFEFEF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- 1. Header (Tetap Diam/Fixed) ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48), // Placeholder untuk balancing
                Text(
                  'Event Detail',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF222B45),
                  ),
                ),
                // Action Icons
                Row(
                  children: [
                    // EDIT BUTTON
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => AddEventBottomSheet(eventToEdit: event),
                        );
                      },
                      child: const Icon(Icons.edit_outlined, size: 24, color: Color(0xFF222B45)),
                    ),
                    const SizedBox(width: 16),
                    // DELETE BUTTON
                    GestureDetector(
                      onTap: () {
                        _confirmDelete(context);
                      },
                      child: const Icon(Icons.delete_outline, size: 24, color: Color(0xFFD4183D)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // --- 2. Content Section (SCROLLABLE) ---
          // Gunakan Flexible + SingleChildScrollView agar bisa discroll jika konten panjang
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    // A. Title & Badge Card
                    _buildInfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: categoryColor),
                            ),
                            child: Text(
                              categoryName,
                              style: GoogleFonts.poppins(
                                color: categoryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // B. Date & Time Card
                    _buildInfoCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _buildIconBox(Icons.calendar_today_outlined),
                              const SizedBox(width: 10),
                              Text(
                                DateFormat('EEEE, MMM d, yyyy').format(event.startTime),
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF444444),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildIconBox(Icons.access_time),
                              const SizedBox(width: 10),
                              Text(
                                '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF444444),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // C. Location Card
                    _buildInfoCard(
                      child: Row(
                        children: [
                          _buildIconBox(Icons.location_on_outlined),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              event.location.isNotEmpty ? event.location : 'No location set',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF444444),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // D. Reminder Card
                    _buildInfoCard(
                      child: Row(
                        children: [
                          _buildIconBox(Icons.notifications_none_outlined),
                          const SizedBox(width: 10),
                          Text(
                            event.reminder,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF444444),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // E. Notes Card
                    _buildInfoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Notes', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            event.description.isNotEmpty ? event.description : 'No notes',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF444444),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Padding tambahan di bawah agar tidak terlalu mepet saat discroll mentok
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (Sisa method helper _buildInfoCard, _buildIconBox, _confirmDelete, dll TETAP SAMA)

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }

  Widget _buildIconBox(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF8DA7E1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Icon(icon, size: 16, color: Colors.white),
    );
  }

  void _confirmDelete(BuildContext context) {
    final isRecurring = event.repeat != 'Does not repeat';

    if (isRecurring) {
      showDeleteRepeatDialog(
        context: context,
        onConfirm: (DeleteMode mode) async {
          await _handleDeleteProcess(context, mode);
        },
      );
    } else {
      showIOSDialog(
        context: context,
        title: "Delete Event",
        message: "Are you sure you want to\ndelete this event?",
        confirmText: "Delete",
        confirmTextColor: const Color(0xFFFF453A),
        onConfirm: () async {
          await _handleDeleteProcess(context, DeleteMode.single);
        },
      );
    }
  }

  Future<void> _handleDeleteProcess(BuildContext context, DeleteMode mode) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      if (event.repeat != 'Does not repeat') {
        await EventService().deleteRecurringEvent(
          userId: userId,
          event: event,
          mode: mode,
        );
      } else {
        await EventService().deleteEvent(userId, event.id!);
      }

      if (context.mounted) {
        Navigator.pop(context);
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Event deleted successfully'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Error deleting event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}