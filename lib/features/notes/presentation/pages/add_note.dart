  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:google_fonts/google_fonts.dart';
  import '../../data/models/category_model.dart';
  import '../../data/models/note_model.dart';
  import '../../data/services/notes_service.dart';
  
  class AddEditNotePage extends StatefulWidget {
    final String? noteId;
  
    const AddEditNotePage({super.key, this.noteId});
  
    @override
    State<AddEditNotePage> createState() => _AddEditNotePageState();
  }
  
  class _AddEditNotePageState extends State<AddEditNotePage> {
    final NoteService _noteService = NoteService();
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _contentController = TextEditingController();
    final FocusNode _contentFocusNode = FocusNode();
  
    NoteModel? _currentNote;
    bool _isModified = false;
  
    @override
    void initState() {
      super.initState();
      if (widget.noteId != null) {
        _loadNote();
      }
      _titleController.addListener(_onTextChanged);
      _contentController.addListener(_onTextChanged);
    }
  
    void _loadNote() {
      _currentNote = _noteService.getNoteById(widget.noteId!);
      if (_currentNote != null) {
        _titleController.text = _currentNote!.title;
        _contentController.text = _currentNote!.content;
      }
    }
  
    void _onTextChanged() {
      if (!_isModified) {
        setState(() {
          _isModified = true;
        });
      }
    }
  
    @override
    void dispose() {
      _titleController.removeListener(_onTextChanged);
      _contentController.removeListener(_onTextChanged);
      _titleController.dispose();
      _contentController.dispose();
      _contentFocusNode.dispose();
      super.dispose();
    }
  
    void _saveNote() {
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();
  
      if (title.isEmpty && content.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note cannot be empty'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
  
      if (widget.noteId == null) {
        // Add new note
        final newNote = NoteModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title.isEmpty ? 'Untitled' : title,
          content: content,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          categoryId: 'all',
          color: _getRandomColor(),
        );
        _noteService.addNote(newNote);
      } else {
        // Update existing note
        if (_currentNote != null) {
          final updatedNote = _currentNote!.copyWith(
            title: title.isEmpty ? 'Untitled' : title,
            content: content,
            updatedAt: DateTime.now(),
          );
          _noteService.updateNote(updatedNote);
        }
      }
  
      Navigator.pop(context, true);
    }
  
    int _getRandomColor() {
      final colors = [
        0xFFE6C4DD,
        0xFFCFE6AF,
        0xFFB4D7F8,
        0xFFE4BA9B,
        0xFFFFBEBE,
        0xFFF4FFBE,
        0xFFFFE4B5,
        0xFFE0BBE4,
        0xFFB5E7A0,
        0xFFFFDAB9,
        0xFFAEC6CF,
        0xFFFDFD96,
      ];
      return colors[DateTime.now().millisecondsSinceEpoch % colors.length];
    }
  
    Future<bool> _onWillPop() async {
      if (_isModified) {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Discard changes?',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              'You have unsaved changes. Do you want to discard them?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: GoogleFonts.poppins()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Discard',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              ),
            ],
          ),
        );
        return result ?? false;
      }
      return true;
    }
  
    String _getCategoryName() {
      if (_currentNote == null) return 'All Notes';
      final category = _noteService.getCategoryById(_currentNote!.categoryId);
      return category?.name ?? 'All Notes';
    }
  
    @override
    Widget build(BuildContext context) {
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () async {
                if (await _onWillPop()) {
                  Navigator.pop(context);
                }
              },
            ),
            title: Text(
              _getCategoryName(),
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                onPressed: () {
                  _showOptionsMenu();
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Title and Date Section
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 16, 25, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Note title',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLines: 1,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) {
                        _contentFocusNode.requestFocus();
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentNote?.formattedDate ?? _getFormattedDate(),
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF7C7B7B),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
  
              const Divider(height: 1, color: Color(0xFFE0E0E0)),
  
              // Content Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 16, 25, 16),
                  child: TextField(
                    controller: _contentController,
                    focusNode: _contentFocusNode,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Start typing...',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
              ),
  
              // Bottom Toolbar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.photo_outlined),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Image feature coming soon')),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.mic_outlined),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Voice feature coming soon')),
                                );
                              },
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _saveNote,
                          icon: const Icon(Icons.check, size: 18),
                          label: Text(
                            'Save',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD732A8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  
    String _getFormattedDate() {
      final now = DateTime.now();
      final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
    }
  
    void _showOptionsMenu() {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                if (widget.noteId != null)
                  ListTile(
                    leading: Icon(
                      _currentNote?.isFavorite == true
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: _currentNote?.isFavorite == true
                          ? Colors.red
                          : null,
                    ),
                    title: Text(
                      _currentNote?.isFavorite == true
                          ? 'Remove from Favorites'
                          : 'Add to Favorites',
                      style: GoogleFonts.poppins(),
                    ),
                    onTap: () {
                      if (_currentNote != null) {
                        _noteService.toggleFavorite(_currentNote!.id);
                        setState(() {
                          _currentNote = _currentNote!.copyWith(
                            isFavorite: !_currentNote!.isFavorite,
                          );
                        });
                      }
                      Navigator.pop(context);
                    },
                  ),
                if (widget.noteId != null)
                  ListTile(
                    leading: const Icon(Icons.drive_file_move_outlined),
                    title: Text('Move to Category', style: GoogleFonts.poppins()),
                    onTap: () {
                      Navigator.pop(context);
                      _showCategorySelector();
                    },
                  ),
                if (widget.noteId != null)
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title: Text(
                      'Delete Note',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _confirmDelete();
                    },
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    }
  
    void _showCategorySelector() {
      // ✅ FIX: Proper filtering dengan type safety
      final allCategories = _noteService.categories;
      final categories = allCategories.where((c) => c.id != 'all').toList();
  
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Move to Category',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...categories.map((CategoryModel category) {
                  final isSelected = _currentNote?.categoryId == category.id;
                  return ListTile(
                    title: Text(category.name, style: GoogleFonts.poppins()),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Color(0xFF5784EB))
                        : null,
                    onTap: () {
                      if (_currentNote != null) {
                        _noteService.moveNoteToCategory(_currentNote!.id, category.id);
                        setState(() {
                          _currentNote = _currentNote!.copyWith(categoryId: category.id);
                        });
                      }
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    }
  
    void _confirmDelete() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Note?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: Text(
            'This action cannot be undone.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            TextButton(
              onPressed: () {
                if (widget.noteId != null) {
                  _noteService.deleteNote(widget.noteId!);
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Go back to notes page
                }
              },
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }
  }