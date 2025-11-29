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
  final FocusNode _editorFocusNode = FocusNode();

  Timer? _autoSaveTimer;
  Timer? _debounceTimer;

  bool _isLoading = false;

  // Flag untuk mendeteksi apakah data berubah
  bool _isDirty = false;

  late DateTime _currentDate;
  int _wordCount = 0;

  String _currentCategoryId = '';
  bool _isFavorite = false;

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

    _quillController = quill.QuillController.basic();

    if (widget.noteId != null) {
      _fetchNoteData();
    }

    // ✅ FIX: Autosave dipercepat jadi 5 detik
    // Autosave hanya berjalan jika noteId TIDAK null (Edit Mode)
    // Ini mencegah duplikat entry saat membuat note baru karena Service generate ID baru terus.
    if (widget.noteId != null) {
      _autoSaveTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_isDirty) {
          _autoSave();
        }
      });
    }

    _titleController.addListener(_onTitleChanged);
    _quillController.addListener(_onContentChanged);
    _editorFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _debounceTimer?.cancel();
    _titleController.dispose();
    _editorFocusNode.dispose();
    _quillController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_editorFocusNode.hasFocus) {
      _updateToolbarState();
    }
  }

  void _onTitleChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isDirty = true);
      }
    });
  }

  void _onContentChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _updateToolbarState();
        _updateWordCount();
        setState(() => _isDirty = true);
      }
    });
  }

  void _updateWordCount() {
    final text = _quillController.document.toPlainText().trim();
    final newWordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;

    if (_wordCount != newWordCount) {
      setState(() {
        _wordCount = newWordCount;
      });
    }
  }

  void _updateToolbarState() {
    final selection = _quillController.selection;
    if (!selection.isValid || selection.baseOffset < 0) {
      return;
    }

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
    try {
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
          _currentCategoryId = note.categoryId;
          _isFavorite = note.isFavorite;
        });
      }
    } catch (e) {
      debugPrint("Error fetching note: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _autoSave() async {
    // Hanya autosave jika ini note lama (punya ID)
    if (widget.noteId != null) {
      await _saveNote();
      if (mounted) setState(() => _isDirty = false);
    }
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final plainText = _quillController.document.toPlainText().trim();

    // Jangan simpan jika kosong sama sekali
    if (title.isEmpty && plainText.isEmpty) return;

    final contentJson = jsonEncode(_quillController.document.toDelta().toJson());

    // ✅ FIX CRASH: Gunakan null check yang aman
    final String safeId = widget.noteId ?? '';
    final bool isEditingExistingNote = widget.noteId != null;

    final note = NoteModel(
      id: safeId,
      title: title,
      content: contentJson,
      createdAt: isEditingExistingNote ? _currentDate : DateTime.now(),
      updatedAt: DateTime.now(),
      categoryId: _currentCategoryId,
      isFavorite: _isFavorite,
    );

    try {
      if (isEditingExistingNote) {
        await _noteService.updateNote(note);
      } else {
        await _noteService.addNote(note);
      }
    } catch (e) {
      debugPrint("Error saving note: $e");
    }
  }

  // --- Formatting Methods (Same as before) ---
  void _applyFormatting(String format) {
    if (!_editorFocusNode.hasFocus) {
      _editorFocusNode.requestFocus();
      Future.delayed(const Duration(milliseconds: 50), () {
        _applyFormattingInternal(format);
      });
    } else {
      _applyFormattingInternal(format);
    }
  }

  void _applyFormattingInternal(String format) {
    final selection = _quillController.selection;
    if (!selection.isValid || selection.baseOffset < 0) {
      final offset = _quillController.document.length - 1;
      _quillController.updateSelection(
        TextSelection.collapsed(offset: offset.clamp(0, _quillController.document.length - 1)),
        quill.ChangeSource.local,
      );
    }

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

    Future.delayed(const Duration(milliseconds: 100), _updateToolbarState);
  }

  void _applyHeading(String heading) {
    if (!_editorFocusNode.hasFocus) {
      _editorFocusNode.requestFocus();
      Future.delayed(const Duration(milliseconds: 50), () {
        _applyHeadingInternal(heading);
      });
    } else {
      _applyHeadingInternal(heading);
    }
  }

  void _applyHeadingInternal(String heading) {
    if (heading == 'h1') {
      _quillController.formatSelection(
          _currentHeading == 'h1' ? quill.Attribute.header : quill.Attribute.h1);
    } else if (heading == 'h2') {
      _quillController.formatSelection(
          _currentHeading == 'h2' ? quill.Attribute.header : quill.Attribute.h2);
    }

    Future.delayed(const Duration(milliseconds: 100), _updateToolbarState);
  }

  void _insertList(String type) {
    if (!_editorFocusNode.hasFocus) {
      _editorFocusNode.requestFocus();
    }

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
    if (!_editorFocusNode.hasFocus) {
      _editorFocusNode.requestFocus();
    }

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

  // ✅ FIX Navigation: Gunakan logic yang aman
  void _handleBack() async {
    // Tutup keyboard dulu agar smooth
    FocusManager.instance.primaryFocus?.unfocus();

    // Save note
    await _saveNote();

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, d MMM y').format(_currentDate);

    // ✅ FIX PopScope: Logic yang lebih robust untuk Android Back Button
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        // Simpan data sebelum keluar
        await _saveNote();

        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        // ✅ Smoothness: Set false agar keyboard tidak mendorong layout secara kasar
        // Konten akan discroll via SingleChildScrollView
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  physics: const BouncingScrollPhysics(), // ✅ Smooth Bouncing Scroll
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      TextField(
                        controller: _titleController,
                        style: GoogleFonts.poppins(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          height: 1.2,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Title',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                      ),
                      const SizedBox(height: 8),
                      _buildMetadata(formattedDate),
                      const SizedBox(height: 24),
                      // Editor Area
                      SizedBox(
                        // Beri tinggi minimal agar scrollable nyaman
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: quill.QuillEditor.basic(
                          focusNode: _editorFocusNode,
                          configurations: quill.QuillEditorConfigurations(
                            controller: _quillController,
                            placeholder: 'Start typing...',
                            padding: const EdgeInsets.only(bottom: 100),
                            readOnly: false,
                            autoFocus: false,
                            expands: false, // Biarkan SingleChildScrollView yang handle scroll utama
                            scrollPhysics: const NeverScrollableScrollPhysics(), // Disable internal scroll
                            customStyles: quill.DefaultStyles(
                              paragraph: quill.DefaultTextBlockStyle(
                                GoogleFonts.poppins(fontSize: 16, color: Colors.black, height: 1.5),
                                const quill.VerticalSpacing(0, 0),
                                const quill.VerticalSpacing(0, 0),
                                null,
                              ),
                              h1: quill.DefaultTextBlockStyle(
                                GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black, height: 1.3),
                                const quill.VerticalSpacing(16, 8),
                                const quill.VerticalSpacing(0, 0),
                                null,
                              ),
                              h2: quill.DefaultTextBlockStyle(
                                GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black, height: 1.3),
                                const quill.VerticalSpacing(12, 6),
                                const quill.VerticalSpacing(0, 0),
                                null,
                              ),
                              lists: quill.DefaultListBlockStyle(
                                GoogleFonts.poppins(fontSize: 16, color: Colors.black, height: 1.5),
                                const quill.VerticalSpacing(0, 0),
                                const quill.VerticalSpacing(0, 6),
                                null,
                                null,
                              ),
                              bold: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                              italic: GoogleFonts.poppins(fontStyle: FontStyle.italic),
                              underline: const TextStyle(decoration: TextDecoration.underline),
                              strikeThrough: const TextStyle(decoration: TextDecoration.lineThrough),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                  'Saving', // Indikator lebih jelas
                  style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
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
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _ToolButton(icon: Icons.format_bold, isActive: _isBold, onTap: () => _applyFormatting('bold')),
            _ToolButton(icon: Icons.format_italic, isActive: _isItalic, onTap: () => _applyFormatting('italic')),
            _ToolButton(icon: Icons.format_underline, isActive: _isUnderline, onTap: () => _applyFormatting('underline')),
            _ToolButton(icon: Icons.format_strikethrough, isActive: _isStrikethrough, onTap: () => _applyFormatting('strikethrough')),
            const SizedBox(width: 8),
            Container(width: 1, height: 30, color: Colors.grey.shade300),
            const SizedBox(width: 8),
            _ToolButton(label: 'H1', isActive: _currentHeading == 'h1', onTap: () => _applyHeading('h1')),
            _ToolButton(label: 'H2', isActive: _currentHeading == 'h2', onTap: () => _applyHeading('h2')),
            const SizedBox(width: 8),
            Container(width: 1, height: 30, color: Colors.grey.shade300),
            const SizedBox(width: 8),
            _ToolButton(icon: Icons.format_list_bulleted, onTap: _showListOptions),
            _ToolButton(icon: Icons.check_box_outlined, onTap: _insertCheckbox),
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
          borderRadius: BorderRadius.circular(8),
        ),
        child: icon != null
            ? Icon(icon, size: 22, color: isActive ? const Color(0xFF5784EB) : Colors.black54)
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