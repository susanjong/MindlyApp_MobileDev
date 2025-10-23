// ...existing code...
import 'package:flutter/material.dart';
import 'package:notesapp/widgets/navbar.dart';

void main() {
  runApp(const MindlyApp());
}

class MindlyApp extends StatelessWidget {
  const MindlyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mindly',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0D5F5F),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
      ),
      home: const HomePage(),
    );
  }
}

// Custom Top AppBar seperti desain
class CustomTopAppBar extends StatelessWidget {
  const CustomTopAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D5F5F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.grid_view_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Mindly',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D5F5F),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.person_outline, size: 24),
                    color: const Color(0xFF1A1A1A),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 24),
                    color: const Color(0xFF1A1A1A),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const CustomTopAppBar(),
          const Expanded(
            child: HomePageContent(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: CustomNavBar(
            selectedIndex: 0,
            onItemTapped: (index) {
              // TODO: ganti dengan navigasi / state management yang kamu pakai.
              // if (index == 0) Navigator.pushReplacementNamed(context, '/home');
            },
          ),
        ),
      ),
    );
  }
}

// Simple wrapper widget supaya kita bisa memberikan non-const params / logic
class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // Pass selectedIndex = 0 (home) dan handler sederhana untuk onItemTapped
      child: CustomNavBar(
        selectedIndex: 0,
        onItemTapped: (index) {
          // TODO: ganti dengan logic navigasi / state management yang kamu pakai.
          // Contoh navigasi sederhana:
          // if (index == 0) Navigator.pushReplacementNamed(context, '/home');
        },
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  const HomePageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GreetingSection(),
            const SizedBox(height: 24),
            const DailyProgressCard(),
            const SizedBox(height: 24),
            const NeedsAttentionSection(),
            const SizedBox(height: 24),
            TodaysEventSection(),
            const SizedBox(height: 24),
            TodaysNotesSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class GreetingSection extends StatelessWidget {
  const GreetingSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good Morning, Jane Doe',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Let's make today productive!",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B6B6B),
          ),
        ),
      ],
    );
  }
}

class DailyProgressCard extends StatelessWidget {
  const DailyProgressCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const progress = 0.5;
    const completedTasks = 2;
    const totalTasks = 4;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE8E8E8),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8BC34A)),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$completedTasks of $totalTasks tasks completed',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B6B6B),
            ),
          ),
        ],
      ),
    );
  }
}

class NeedsAttentionSection extends StatelessWidget {
  const NeedsAttentionSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 20),
            SizedBox(width: 8),
            Text(
              'Needs Attention',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AttentionItem(
          title: 'Meeting with marketing team',
          tag: 'urgent',
          time: 'Today',
        ),
      ],
    );
  }
}

class AttentionItem extends StatelessWidget {
  final String title;
  final String tag;
  final String time;

  const AttentionItem({
    Key? key,
    required this.title,
    required this.tag,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.circle_outlined, color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Color(0xFF6B6B6B)),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B6B6B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFFF9800),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TodaysEventSection extends StatelessWidget {
  final List<EventModel> events = [
    EventModel(
      title: 'Team meeting preparation',
      time: 'Today, 3:00 PM',
      location: 'PT XYZ (Office)',
      color: const Color(0xFFFF6B6B),
    ),
    EventModel(
      title: 'Update Website Client',
      time: 'Today, 2:00 PM',
      location: 'Remote',
      color: const Color(0xFFFFA726),
    ),
    EventModel(
      title: 'Review Design Mockup',
      time: 'Today, 4:00 PM',
      location: 'Coffee Shop',
      color: const Color(0xFF66BB6A),
    ),
  ];

  TodaysEventSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_today, color: Color(0xFF0D5F5F), size: 20),
                SizedBox(width: 8),
                Text(
                  "Today's Event",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All →',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF0D5F5F),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...events.map((event) => EventCard(event: event)).toList(),
      ],
    );
  }
}

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: event.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: Color(0xFF6B6B6B)),
                    const SizedBox(width: 4),
                    Text(
                      event.time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B6B6B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF6B6B6B)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B6B6B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TodaysNotesSection extends StatelessWidget {
  final List<NoteModel> notes = [
    NoteModel(
      title: 'Meeting Insights',
      content: 'Key takeaways from client meeting: focus on user experience improvements...',
      timeAgo: '2 hours ago',
    ),
    NoteModel(
      title: 'Meeting Insights',
      content: 'Key takeaways from client meeting: focus on user experience improvements...',
      timeAgo: '3 hours ago',
    ),
  ];

  TodaysNotesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.note_outlined, color: Color(0xFFFF9800), size: 20),
                SizedBox(width: 8),
                Text(
                  "Today's Notes",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All →',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF0D5F5F),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...notes.map((note) => NoteCard(note: note)).toList(),
      ],
    );
  }
}

class NoteCard extends StatelessWidget {
  final NoteModel note;

  const NoteCard({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Text(
                note.timeAgo,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B6B6B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note.content,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4A4A4A),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Models
class EventModel {
  final String title;
  final String time;
  final String location;
  final Color color;

  EventModel({
    required this.title,
    required this.time,
    required this.location,
    required this.color,
  });
}

class NoteModel {
  final String title;
  final String content;
  final String timeAgo;

  NoteModel({
    required this.title,
    required this.content,
    required this.timeAgo,
  });
}
