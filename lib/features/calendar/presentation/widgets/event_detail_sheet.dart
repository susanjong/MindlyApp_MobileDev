import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notesapp/core/widgets/dialog/alert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../features/calendar/data/models/event_model.dart';
import '../../../../features/calendar/data/services/category_service.dart';
import '../../../../features/calendar/data/services/event_service.dart';
import 'add_event.dart'; // Import AddEvent untuk mode Edit

class EventDetailSheet extends StatelessWidget {
  final Event event;
  final Category? category; // Pass kategori agar warna/nama sesuai

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

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFEFEFEF), // Background abu-abu sesuai Figma
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- 1. Header (White with Title & Action Icons) ---
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
                // Placeholder left icon agar title di tengah (opsional)
                const SizedBox(width: 48),

                Text(
                  'Event Detail',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF222B45),
                  ),
                ),

                // Action Icons (Edit & Delete)
                Row(
                  children: [
                    // EDIT BUTTON
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Tutup detail dulu
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

          // --- 2. Content Section ---
          Padding(
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
                      // Date Row
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
                      // Time Row
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
                          // Gunakan description sbg lokasi sementara, atau tambah field location di model
                          event.description.isNotEmpty ? 'Location details...' : 'No location set',
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
                        '15 minutes before', // Hardcoded for now, adjust if model has reminder
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
                          // Icon note kecil? atau text label "Notes"
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
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

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
    // Menggunakan IOSDialog yang sudah ada di project Anda
    showIOSDialog(
      context: context,
      title: "Delete Event",
      message: "Are you sure you want to\ndelete this event?",
      cancelText: "Cancel",
      confirmText: "Delete",
      confirmTextColor: const Color(0xFFFF453A), // Warna Merah
      onCancel: () {},
      onConfirm: () async {
        final userId = FirebaseAuth.instance.currentUser!.uid;
        await EventService().deleteEvent(userId, event.id!);
        if (context.mounted) {
          Navigator.pop(context); // Tutup Detail Sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event deleted successfully')),
          );
        }
      },
    );
  }
}