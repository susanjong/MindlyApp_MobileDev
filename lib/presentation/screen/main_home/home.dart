import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:notesapp/widgets/navbar.dart';
import 'package:notesapp/widgets/custom_top_app_bar.dart';
import 'package:notesapp/models/event_model.dart';
import 'package:notesapp/models/note_model.dart';
import 'package:notesapp/widgets/colors.dart';
import 'package:notesapp/widgets/font_style.dart';
import 'package:notesapp/presentation/screen/notes/awalnotes.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isTaskCompleted = false;
  bool _isNavBarVisible = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      // Scroll ke bawah - sembunyikan navbar
      if (_isNavBarVisible) {
        setState(() {
          _isNavBarVisible = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      // Scroll ke atas - tampilkan navbar
      if (!_isNavBarVisible) {
        setState(() {
          _isNavBarVisible = true;
        });
      }
    }
  }

  // just sample data
  List<EventModel> _getEvents() {
    return [
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
  }

  // Sample Notes Data
  List<NoteModel> _getNotes() {
    return [
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
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEvents();
    final notes = _getNotes();
    const completedTasks = 2;
    const totalTasks = 4;
    final progress = completedTasks / totalTasks;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CustomTopAppBar(
            onProfileTap: () {
              // TODO: Navigate to profile screen
            },
            onNotificationTap: () {
              // TODO: Navigate to notifications screen
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ========== GREETING SECTION ==========
                    const Text(
                      'Good Morning, Jane Doe',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Let's make today productive!",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B6B6B),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ========== Daily progress card ==========
                    Container(
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
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF8BC34A),
                              ),
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
                    ),
                    const SizedBox(height: 24),

                    // ========== NEEDS ATTENTION SECTION ==========
                    Row(
                      children: const [
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isTaskCompleted = !_isTaskCompleted;
                              });
                            },
                            child: Container(
                              width: 33,
                              height: 33,
                              decoration: ShapeDecoration(
                                color: _isTaskCompleted
                                    ? const Color(0xFF5784EB)
                                    : Colors.transparent,
                                shape: OvalBorder(
                                  side: BorderSide(
                                    width: 1.50,
                                    color: const Color(0xFF5784EB),
                                  ),
                                ),
                              ),
                              child: _isTaskCompleted
                                  ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Color(0xFF6B6B6B),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Today',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B6B6B),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF3E0),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'urgent',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFFFF9800),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Meeting with marketing team',
                                  style: TextStyle(
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
                    ),
                    const SizedBox(height: 24),

                    // ========== TODAY'S EVENT SECTION ==========
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
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

                    // Event Cards
                    ...events.map((event) => Container(
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
                                    const Icon(
                                      Icons.access_time,
                                      size: 12,
                                      color: Color(0xFF6B6B6B),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      event.time,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B6B6B),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 12,
                                      color: Color(0xFF6B6B6B),
                                    ),
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
                    )).toList(),
                    const SizedBox(height: 24),

                    // ========== TODAY'S NOTES SECTION ==========
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
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

                    // Note Cards
                    ...notes.map((note) => Container(
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
                    )).toList(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isNavBarVisible ? null : 0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _isNavBarVisible ? 1.0 : 0.0,
          child: Container(
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
                  // TODO: Implement navigation logic
                  print('Navbar item tapped: $index');
                  // Contoh navigasi:
                  if (index == 1) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NotesPage()));
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}