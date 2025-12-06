import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EventSearchDelegate extends SearchDelegate {
  final Map<DateTime, List<Map<String, dynamic>>> events;

  EventSearchDelegate({required this.events});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return Center(child: Text('Search your events...', style: GoogleFonts.poppins()));
    }

    // Filter Logic
    final List<Map<String, dynamic>> results = [];
    events.forEach((date, eventList) {
      for (var event in eventList) {
        if (event['title'].toString().toLowerCase().contains(query.toLowerCase())) {
          results.add({
            ...event,
            'date': date, // Tambahkan tanggal ke hasil agar bisa ditampilkan
          });
        }
      }
    });

    if (results.isEmpty) {
      return Center(child: Text('No events found.', style: GoogleFonts.poppins()));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        final date = item['date'] as DateTime;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: item['color'],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['title'],
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${DateFormat('dd MMM yyyy').format(date)} • ${item['time']}',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}