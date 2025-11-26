import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/note_model.dart';
import 'package:intl/intl.dart';
import '../../data/services/note_service.dart';

class NoteEditorPage extends StatefulWidget {
  final String? noteId;

  const NoteEditorPage({super.key, this.noteId});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final NoteService _noteService = NoteService();

  bool _isLoading = false;
  bool _isEditing = false;
  bool _isBookmarked = false; // ✅ Track bookmark status
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _isEditing = widget.noteId != null;

    if (_isEditing) {
      _fetchNoteData();
    }
  }

  Future<void> _fetchNoteData() async {
    setState(() => _isLoading = true);
    final note = await _noteService.getNoteById(widget.noteId!);
    if (note != null) {
      _titleController.text = note.title;
      _contentController.text = note.content;
      setState(() {
        _currentDate = note.updatedAt;
        // ✅ Set bookmark status berdasarkan categoryId
        _isBookmarked = note.categoryId == 'bookmarks';
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) return;

    if (_isEditing) {
      // Logic Edit (Update ke Firestore)
      final updatedNote = NoteModel(
        id: widget.noteId!,
        title: title,
        content: content,
        createdAt: _currentDate,
        updatedAt: DateTime.now(),
        // ✅ Simpan categoryId berdasarkan bookmark status
        categoryId: _isBookmarked ? 'bookmarks' : 'all',
        isFavorite: false,
      );
      await _noteService.updateNote(updatedNote);
    } else {
      // Logic Add (Create ke Firestore)
      final newNote = NoteModel(
        id: '',
        title: title,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        // ✅ Set categoryId berdasarkan bookmark
        categoryId: _isBookmarked ? 'bookmarks' : 'all',
        isFavorite: false,
      );
      await _noteService.addNote(newNote);
    }
  }

  // ✅ Toggle bookmark function
  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  void _handleBack() async {
    await _saveNote();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, d MMM y').format(_currentDate);
    final formattedTime = DateFormat('HH:mm').format(_currentDate);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        await _saveNote();
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              // === Custom App Bar ===
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, size: 32, color: Colors.black),
                          onPressed: _handleBack,
                        ),
                        Text(
                          'All Notes',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            letterSpacing: -0.32,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Time Display
                        Text(
                          formattedTime,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // ✅ Bookmark Icon - FIXED
                        GestureDetector(
                          onTap: _toggleBookmark,
                          child: Icon(
                            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            size: 24,
                            color: _isBookmarked ? const Color(0xFFFFEB3B) : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    )
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // === Title Input ===
                      TextField(
                        controller: _titleController,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          height: 1.2,
                          letterSpacing: -0.48,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Title',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null,
                      ),

                      // === Date Display ===
                      const SizedBox(height: 8),
                      Text(
                        formattedDate,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF7C7B7B),
                          letterSpacing: -0.24,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // === Content Input ===
                      TextField(
                        controller: _contentController,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Start typing...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // === Bottom Formatting Toolbar ===
              _buildBottomToolbar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xEACDCFD3),
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: [
          _ToolButton(label: 'B', isBold: true),
          _ToolButton(label: 'I', isItalic: true),
          _ToolButton(label: 'U', isUnderline: true),
          _ToolButton(label: 'S', isStrikethrough: true),
          const VerticalDivider(indent: 10, endIndent: 10),
          _ToolButton(label: 'H1', fontSize: 14),
          _ToolButton(label: 'H2', fontSize: 12),
          const VerticalDivider(indent: 10, endIndent: 10),
          _ToolButton(icon: Icons.format_list_bulleted),
          _ToolButton(icon: Icons.check_box_outlined),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final bool isStrikethrough;
  final double fontSize;

  const _ToolButton({
    this.label,
    this.icon,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.isStrikethrough = false,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFE),
        borderRadius: BorderRadius.circular(4.6),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF898A8D),
            blurRadius: 0,
            offset: Offset(0, 1),
          )
        ],
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, size: 20, color: Colors.black)
            : Text(
          label ?? '',
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            decoration: isUnderline
                ? TextDecoration.underline
                : (isStrikethrough ? TextDecoration.lineThrough : null),
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}