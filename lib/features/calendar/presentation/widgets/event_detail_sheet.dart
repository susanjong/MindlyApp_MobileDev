import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/widgets/others/snackbar.dart';
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

  // Helper: Mengonversi string Hex color menjadi objek Color Flutter
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    // Menyiapkan warna dan nama kategori, fallback ke default jika null
    final categoryColor = category != null
        ? _getColorFromHex(category!.color)
        : const Color(0xFF5683EB);
    final categoryName = category?.name ?? 'General';
    final double maxSheetHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
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
          // Bagian Header (Judul & Aksi Edit/Delete)
          _buildHeader(context),

          const SizedBox(height: 10),

          // Bagian Konten Scrollable
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    _buildTitleSection(categoryName, categoryColor),
                    const SizedBox(height: 10),
                    _buildDateTimeSection(),
                    const SizedBox(height: 10),
                    _buildLocationSection(),
                    const SizedBox(height: 10),
                    _buildReminderSection(),
                    const SizedBox(height: 10),
                    _buildNotesSection(),
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

  // --- Widget Builders (UI Separation) ---

  // Membangun header sheet dengan tombol edit dan delete
  Widget _buildHeader(BuildContext context) {
    return Container(
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
          const SizedBox(width: 48), // Spacer untuk keseimbangan layout
          Text(
            'Event Detail',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF222B45),
            ),
          ),
          Row(
            children: [
              // Tombol Edit
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
              // Tombol Delete
              GestureDetector(
                onTap: () => _confirmDelete(context),
                child: const Icon(Icons.delete_outline, size: 24, color: Color(0xFFD4183D)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Bagian Judul dan Tag Kategori
  Widget _buildTitleSection(String categoryName, Color categoryColor) {
    return _buildInfoCard(
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
    );
  }

  // Bagian Tanggal dan Waktu
  Widget _buildDateTimeSection() {
    return _buildInfoCard(
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
    );
  }

  // Bagian Lokasi
  Widget _buildLocationSection() {
    return _buildInfoCard(
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
    );
  }

  // Bagian Pengingat (Reminder)
  Widget _buildReminderSection() {
    return _buildInfoCard(
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
    );
  }

  // Bagian Catatan (Description)
  Widget _buildNotesSection() {
    return _buildInfoCard(
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
    );
  }

  // Wrapper umum untuk kartu informasi
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

  // Wrapper umum untuk ikon dengan background biru muda
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

  // --- Business Logic (Action Handlers) ---

  // Menentukan jenis dialog konfirmasi hapus (Single atau Recurring)
  void _confirmDelete(BuildContext context) {
    final isRecurring = event.repeat != 'Does not repeat' || event.parentEventId != null;

    if (isRecurring) {
      showDeleteRepeatDialog(
        context: context,
        onConfirm: (DeleteMode mode) {
          _handleDeleteProcess(context, mode);
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

  // Eksekusi penghapusan ke Firebase melalui Service
  Future<void> _handleDeleteProcess(BuildContext context, DeleteMode mode) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final eventService = EventService();

    try {
      // Hapus event tunggal (single atau recurring yang diputus rantainya)
      if (mode == DeleteMode.single && (event.repeat == 'Does not repeat' && event.parentEventId == null)) {
        await eventService.deleteEvent(userId, event.id!);
      } else {
        // Hapus event berulang sesuai mode (following/all)
        await eventService.deleteRecurringEvent(
          userId: userId,
          event: event,
          mode: mode,
        );
      }

      if (context.mounted) {
        Navigator.pop(context);
        Snackbar.success(context, _getSuccessMessage(mode));
      }
    } catch (e) {
      if (context.mounted) {
        Snackbar.error(context, 'Error: $e');
      }
    }
  }

  // Mengambil pesan sukses berdasarkan mode hapus
  String _getSuccessMessage(DeleteMode mode) {
    switch (mode) {
      case DeleteMode.single:
        return 'Event deleted successfully.';
      case DeleteMode.following:
        return 'This & following events deleted.';
      case DeleteMode.all:
        return 'All events in series deleted.';
    }
  }
}