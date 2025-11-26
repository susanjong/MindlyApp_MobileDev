import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/note_model.dart';
import 'package:intl/intl.dart';
import '../../data/services/note_service.dart';
import 'dart:async';

class NoteEditorPage extends StatefulWidget {
  final String? noteId;

  const NoteEditorPage({super.key, this.noteId});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  final _titleController = TextEditingController();
  late quill.QuillController _quillController;
  final NoteService _noteService = NoteService();

  Timer? _autoSaveTimer;
  Timer? _debounceTimer;

  bool _isLoading = false;
  bool _isEditing = false;
  bool _isBookmarked = false;
  bool _isDirty = false;
  late DateTime _currentDate;
  int _wordCount = 0;

  // Toolbar state
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  bool _isStrikethrough = false;
  String _currentHeading = 'normal';

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _isEditing = widget.noteId != null;

    // Initialize controller
    _quillController = quill.QuillController.basic();

    if (_isEditing) {
      _fetchNoteData();
    }

    // Auto-save timer (reduced frequency)
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isDirty) {
        _autoSave();
      }
    });

    // Debounced listeners
    _titleController.addListener(_onTitleChanged);
    _quillController.addListener(_onContentChanged);
  }

  // Debounced title change
  void _onTitleChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() => _isDirty = true);
      }
    });
  }

  // Debounced content change
  void _onContentChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) {
        _updateToolbarState();
        _updateWordCount();
      }
    });
  }

  void _updateWordCount() {
    final text = _quillController.document.toPlainText().trim();
    final newWordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;

    if (_wordCount != newWordCount) {
      setState(() {
        _wordCount = newWordCount;
        _isDirty = true;
      });
    }
  }

  void _updateToolbarState() {
    final styles = _quillController.getSelectionStyle();

    final newBold = styles.containsKey(quill.Attribute.bold.key);
    final newItalic = styles.containsKey(quill.Attribute.italic.key);
    final newUnderline = styles.containsKey(quill.Attribute.underline.key);
    final newStrikethrough = styles.containsKey(quill.Attribute.strikeThrough.key);

    String newHeading = 'normal';
    final headerAttr = styles.attributes[quill.Attribute.header.key];
    if (headerAttr != null) {
      if (headerAttr.value == 1) {
        newHeading = 'h1';
      } else if (headerAttr.value == 2) {
        newHeading = 'h2';
      }
    }

    // Only update if changed
    if (_isBold != newBold ||
        _isItalic != newItalic ||
        _isUnderline != newUnderline ||
        _isStrikethrough != newStrikethrough ||
        _currentHeading != newHeading) {
      setState(() {
        _isBold = newBold;
        _isItalic = newItalic;
        _isUnderline = newUnderline;
        _isStrikethrough = newStrikethrough;
        _currentHeading = newHeading;
      });
    }
  }

  Future<void> _fetchNoteData() async {
    setState(() => _isLoading = true);
    final note = await _noteService.getNoteById(widget.noteId!);
    if (note != null && mounted) {
      _titleController.text = note.title;

      try {
        final json = jsonDecode(note.content);
        _quillController = quill.QuillController(
          document: quill.Document.fromJson(json),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _quillController = quill.QuillController(
          document: quill.Document()..insert(0, note.content),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }

      _quillController.addListener(_onContentChanged);

      setState(() {
        _currentDate = note.updatedAt;
        _isBookmarked = note.categoryId == 'bookmarks';
      });
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _autoSave() async {
    await _saveNote();
    if (mounted) setState(() => _isDirty = false);
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final contentJson = jsonEncode(_quillController.document.toDelta().toJson());
    final plainText = _quillController.document.toPlainText().trim();

    if (title.isEmpty && plainText.isEmpty) return;

    final note = NoteModel(
      id: _isEditing ? widget.noteId! : '',
      title: title,
      content: contentJson,
      createdAt: _isEditing ? _currentDate : DateTime.now(),
      updatedAt: DateTime.now(),
      categoryId: _isBookmarked ? 'bookmarks' : 'all',
      isFavorite: false,
    );

    if (_isEditing) {
      await _noteService.updateNote(note);
    } else {
      await _noteService.addNote(note);
      if (mounted) setState(() => _isEditing = true);
    }
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
      _isDirty = true;
    });
  }

  void _applyFormatting(String format) {
    switch (format) {
      case 'bold':
        _quillController.formatSelection(!_isBold
            ? quill.Attribute.bold
            : quill.Attribute.clone(quill.Attribute.bold, null));
        break;
      case 'italic':
        _quillController.formatSelection(!_isItalic
            ? quill.Attribute.italic
            : quill.Attribute.clone(quill.Attribute.italic, null));
        break;
      case 'underline':
        _quillController.formatSelection(!_isUnderline
            ? quill.Attribute.underline
            : quill.Attribute.clone(quill.Attribute.underline, null));
        break;
      case 'strikethrough':
        _quillController.formatSelection(!_isStrikethrough
            ? quill.Attribute.strikeThrough
            : quill.Attribute.clone(quill.Attribute.strikeThrough, null));
        break;
    }
  }

  void _applyHeading(String heading) {
    if (heading == 'h1') {
      _quillController.formatSelection(
          _currentHeading == 'h1' ? quill.Attribute.header : quill.Attribute.h1);
    } else if (heading == 'h2') {
      _quillController.formatSelection(
          _currentHeading == 'h2' ? quill.Attribute.header : quill.Attribute.h2);
    }
  }

  void _insertList(String type) {
    if (type == 'bullet') {
      if (_quillController.getSelectionStyle().attributes[quill.Attribute.list.key]?.value == 'bullet') {
        _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.ul, null));
      } else {
        _quillController.formatSelection(quill.Attribute.ul);
      }
    } else {
      if (_quillController.getSelectionStyle().attributes[quill.Attribute.list.key]?.value == 'ordered') {
        _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.ol, null));
      } else {
        _quillController.formatSelection(quill.Attribute.ol);
      }
    }
  }

  void _insertCheckbox() {
    if (_quillController.getSelectionStyle().attributes[quill.Attribute.list.key]?.value == 'unchecked') {
      _quillController.formatSelection(quill.Attribute.clone(quill.Attribute.unchecked, null));
    } else {
      _quillController.formatSelection(quill.Attribute.unchecked);
    }
  }

  void _showListOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text('Choose List Type', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.circle, size: 8),
              title: const Text('Bullet List'),
              onTap: () { Navigator.pop(context); _insertList('bullet'); },
            ),
            ListTile(
              leading: const Icon(Icons.format_list_numbered),
              title: const Text('Numbered List'),
              onTap: () { Navigator.pop(context); _insertList('numbered'); },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _handleBack() async {
    await _saveNote();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _debounceTimer?.cancel();
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, d MMM y').format(_currentDate);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        await _saveNote();
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              // Header
              _buildHeader(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Title Field
                      TextField(
                        controller: _titleController,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          height: 1.2,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Title',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                      ),

                      const SizedBox(height: 8),

                      // Metadata
                      _buildMetadata(formattedDate),

                      const SizedBox(height: 24),

                      // Quill Editor
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 300,
                        child: quill.QuillEditor.basic(
                          configurations: quill.QuillEditorConfigurations(
                            controller: _quillController,
                            placeholder: 'Start typing...',
                            padding: const EdgeInsets.only(bottom: 50),
                            readOnly: false,
                            autoFocus: false,
                            expands: false,
                            scrollPhysics: const ClampingScrollPhysics(),
                            customStyles: quill.DefaultStyles(
                              // Paragraph (Normal Text)
                              paragraph: quill.DefaultTextBlockStyle(
                                GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.black,
                                  height: 1.5,
                                ),
                                const quill.VerticalSpacing(0, 0),
                                const quill.VerticalSpacing(0, 0),
                                null,
                              ),
                              // Heading 1
                              h1: quill.DefaultTextBlockStyle(
                                GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                  height: 1.3,
                                ),
                                const quill.VerticalSpacing(16, 8),
                                const quill.VerticalSpacing(0, 0),
                                null,
                              ),
                              // Heading 2
                              h2: quill.DefaultTextBlockStyle(
                                GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  height: 1.3,
                                ),
                                const quill.VerticalSpacing(12, 6),
                                const quill.VerticalSpacing(0, 0),
                                null,
                              ),
                              // Ordered List (Numbered)
                              lists: quill.DefaultListBlockStyle(
                                GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.black,
                                  height: 1.5,
                                ),
                                const quill.VerticalSpacing(0, 0),
                                const quill.VerticalSpacing(0, 6),
                                null,
                                null,
                              ),
                              // Bold
                              bold: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                              // Italic
                              italic: GoogleFonts.poppins(fontStyle: FontStyle.italic),
                              // Underline
                              underline: const TextStyle(decoration: TextDecoration.underline),
                              // Strikethrough
                              strikeThrough: const TextStyle(decoration: TextDecoration.lineThrough),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Toolbar
              _buildBottomToolbar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
              Text('All Notes', style: GoogleFonts.poppins(fontSize: 16)),
            ],
          ),
          Row(
            children: [
              if (_isDirty)
                Text(
                  'Saving...',
                  style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _toggleBookmark,
                child: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: _isBookmarked ? const Color(0xFFFFEB3B) : Colors.black,
                ),
              ),
              const SizedBox(width: 16),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetadata(String formattedDate) {
    return Row(
      children: [
        Text(
          formattedDate,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF7C7B7B),
          ),
        ),
        if (_wordCount > 0) ...[
          const SizedBox(width: 12),
          Text(
            '• $_wordCount words',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF7C7B7B),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      height: 50,
      width: double.infinity,
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _ToolButton(
              icon: Icons.format_bold,
              isActive: _isBold,
              onTap: () => _applyFormatting('bold'),
            ),
            _ToolButton(
              icon: Icons.format_italic,
              isActive: _isItalic,
              onTap: () => _applyFormatting('italic'),
            ),
            _ToolButton(
              icon: Icons.format_underline,
              isActive: _isUnderline,
              onTap: () => _applyFormatting('underline'),
            ),
            _ToolButton(
              icon: Icons.format_strikethrough,
              isActive: _isStrikethrough,
              onTap: () => _applyFormatting('strikethrough'),
            ),
            const SizedBox(width: 8),
            Container(width: 1, height: 30, color: Colors.grey.shade300),
            const SizedBox(width: 8),
            _ToolButton(
              label: 'H1',
              isActive: _currentHeading == 'h1',
              onTap: () => _applyHeading('h1'),
            ),
            _ToolButton(
              label: 'H2',
              isActive: _currentHeading == 'h2',
              onTap: () => _applyHeading('h2'),
            ),
            const SizedBox(width: 8),
            Container(width: 1, height: 30, color: Colors.grey.shade300),
            const SizedBox(width: 8),
            _ToolButton(
              icon: Icons.format_list_bulleted,
              onTap: _showListOptions,
            ),
            _ToolButton(
              icon: Icons.check_box_outlined,
              onTap: _insertCheckbox,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool isActive;
  final VoidCallback? onTap;

  const _ToolButton({
    this.label,
    this.icon,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE8F0FE) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: icon != null
            ? Icon(
          icon,
          size: 20,
          color: isActive ? const Color(0xFF5784EB) : Colors.black54,
        )
            : Text(
          label ?? '',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? const Color(0xFF5784EB) : Colors.black54,
          ),
        ),
      ),
    );
  }
}