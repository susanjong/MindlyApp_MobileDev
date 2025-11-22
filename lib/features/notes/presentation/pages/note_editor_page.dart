import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/note_model.dart';
import '../../data/services/note_service.dart';

class NoteEditorPage extends StatefulWidget {
  final String? noteId;

  const NoteEditorPage({super.key, this.noteId});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  // Services & Controllers
  final NoteService _noteService = NoteService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _contentFocusNode = FocusNode();

  // State
  NoteModel? _note;
  bool _hasChanges = false;

  // Computed
  bool get _isEditMode => widget.noteId != null;
  String get _pageTitle => _isEditMode ? _getCategoryName() : 'New Note';

  @override
  void initState() {
    super.initState();
    _loadNote();
    _titleController.addListener(_markAsChanged);
    _contentController.addListener(_markAsChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_markAsChanged);
    _contentController.removeListener(_markAsChanged);
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _loadNote() {
    if (_isEditMode) {
      _note = _noteService.getNoteById(widget.noteId!);
      if (_note != null) {
        _titleController.text = _note!.title;
        _contentController.text = _note!.content;
      }
    }
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  String _getCategoryName() {
    if (_note == null) return 'All Notes';
    return _noteService.getCategoryById(_note!.categoryId)?.name ?? 'All Notes';
  }

  // === Actions ===

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      _showMessage('Note cannot be empty', isError: true);
      return;
    }

    final finalTitle = title.isEmpty ? 'Untitled' : title;

    if (_isEditMode && _note != null) {
      // Update existing note
      _noteService.updateNote(_note!.copyWith(
        title: finalTitle,
        content: content,
        updatedAt: DateTime.now(),
      ));
    } else {
      // Create new note
      _noteService.addNote(NoteModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: finalTitle,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        categoryId: 'all',
        color: _generateRandomColor(),
      ));
    }

    Navigator.pop(context, true);
  }

  void _toggleFavorite() {
    if (_note != null) {
      _noteService.toggleFavorite(_note!.id);
      setState(() {
        _note = _note!.copyWith(isFavorite: !_note!.isFavorite);
      });
    }
  }

  void _deleteNote() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Note?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('This action cannot be undone.', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _noteService.deleteNote(widget.noteId!);
              Navigator.pop(ctx);
              Navigator.pop(context, true);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showMoveDialog() {
    final categories = _noteService.categories.where((c) => c.id != 'all').toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSheetHandle(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Move to Category',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              ...categories.map((cat) => ListTile(
                title: Text(cat.name, style: GoogleFonts.poppins()),
                trailing: _note?.categoryId == cat.id
                    ? const Icon(Icons.check, color: Color(0xFF5784EB))
                    : null,
                onTap: () {
                  _noteService.moveNoteToCategory(_note!.id, cat.id);
                  setState(() {
                    _note = _note!.copyWith(categoryId: cat.id);
                  });
                  Navigator.pop(ctx);
                },
              )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSheetHandle(),
              ListTile(
                leading: Icon(
                  _note?.isFavorite == true ? Icons.favorite : Icons.favorite_border,
                  color: _note?.isFavorite == true ? Colors.red : null,
                ),
                title: Text(
                  _note?.isFavorite == true ? 'Remove from Favorites' : 'Add to Favorites',
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  _toggleFavorite();
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.drive_file_move_outlined),
                title: Text('Move to Category', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(ctx);
                  _showMoveDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Delete Note', style: GoogleFonts.poppins(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteNote();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Discard changes?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('You have unsaved changes.', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Editing'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.orange : Colors.green,
      ),
    );
  }

  int _generateRandomColor() {
    const colors = [
      0xFFE6C4DD, 0xFFCFE6AF, 0xFFB4D7F8, 0xFFE4BA9B,
      0xFFFFBEBE, 0xFFF4FFBE, 0xFFFFE4B5, 0xFFE0BBE4,
      0xFFB5E7A0, 0xFFFFDAB9, 0xFFAEC6CF, 0xFFFDFD96,
    ];
    return colors[DateTime.now().millisecondsSinceEpoch % colors.length];
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Widget _buildSheetHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // === Build ===

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildTitleSection(),
            const Divider(height: 1, color: Color(0xFFE8E8E8)),
            _buildContentSection(),
            _buildToolbar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () async {
          if (await _onWillPop()) Navigator.pop(context);
        },
      ),
      title: Text(
        _pageTitle,
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        if (_isEditMode)
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: _showOptionsMenu,
          ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: 'Note title',
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey.shade400,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _contentFocusNode.requestFocus(),
          ),
          const SizedBox(height: 8),
          Text(
            _note?.formattedDate ?? _getCurrentDate(),
            style: GoogleFonts.poppins(
              color: const Color(0xFF9E9E9E),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        child: TextField(
          controller: _contentController,
          focusNode: _contentFocusNode,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.black87,
            height: 1.6,
          ),
          decoration: InputDecoration(
            hintText: 'Start typing your note...',
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey.shade400,
              fontSize: 16,
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
    );
  }

  Widget _buildToolbar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Left side: additional actions
              IconButton(
                icon: Icon(Icons.image_outlined, color: Colors.grey.shade600),
                onPressed: () => _showMessage('Image feature coming soon'),
              ),
              IconButton(
                icon: Icon(Icons.mic_outlined, color: Colors.grey.shade600),
                onPressed: () => _showMessage('Voice feature coming soon'),
              ),

              const Spacer(),

              // Right side: Save button
              FilledButton.icon(
                onPressed: _saveNote,
                icon: const Icon(Icons.check, size: 18),
                label: Text(
                  _isEditMode ? 'Update' : 'Save',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD732A8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}