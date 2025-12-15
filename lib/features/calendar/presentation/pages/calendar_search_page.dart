import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/models/event_model.dart';
import '../../data/services/category_service.dart';

class CalendarSearchPage extends StatefulWidget {
  final List<Event> allEvents;
  final Map<String, Category> categories;

  const CalendarSearchPage({
    super.key,
    required this.allEvents,
    required this.categories,
  });

  @override
  State<CalendarSearchPage> createState() => _CalendarSearchPageState();
}

class _CalendarSearchPageState extends State<CalendarSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Event> _searchResults = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _query = _searchController.text.trim().toLowerCase();
      if (_query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = widget.allEvents.where((event) {
          return event.title.toLowerCase().contains(_query) ||
              event.description.toLowerCase().contains(_query);
        }).toList();

        // Sort berdasarkan waktu terdekat
        _searchResults.sort((a, b) => a.startTime.compareTo(b.startTime));
      }
    });
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER & SEARCH BAR (DIGABUNG DALAM SATU ROW) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 10, 21.5, 10), // Adjust padding kiri dikit utk icon
              child: Row(
                children: [
                  // 1. Back Button
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 32, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),

                  // 2. Search Bar (Menggunakan Expanded agar mengisi sisa ruang)
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFD9D9D9)),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: Color(0xFF6A6E76),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              autofocus: true, // Langsung aktif saat dibuka
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search events...',
                                hintStyle: GoogleFonts.poppins(
                                  color: const Color(0xFF6A6E76),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_query.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                              },
                              child: const Icon(
                                Icons.clear,
                                color: Color(0xFF6A6E76),
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // --- SEARCH RESULTS LIST ---
            Expanded(
              child: _query.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_note, size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text('Type to search events', style: GoogleFonts.poppins(color: Colors.grey)),
                  ],
                ),
              )
                  : _searchResults.isEmpty
                  ? Center(
                child: Text('No events found', style: GoogleFonts.poppins(color: Colors.grey)),
              )
                  : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final event = _searchResults[index];
                  final category = widget.categories[event.categoryId];

                  // Warna card
                  Color cardColor = const Color(0xFFFBAE38); // Default
                  if (category != null) {
                    try {
                      cardColor = _getColorFromHex(category.color);
                    } catch (_) {}
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // --- BAGIAN KIRI: TANGGAL ---
                        SizedBox(
                          width: 50,
                          child: Column(
                            children: [
                              Text(
                                DateFormat('MMM').format(event.startTime),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1A1A),
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('d').format(event.startTime),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1A1A),
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // --- BAGIAN KANAN: AGENDA CARD ---
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}