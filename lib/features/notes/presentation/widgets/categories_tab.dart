import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/dialog/alert_dialog.dart';
import '../../data/models/category_model.dart';
import '../../data/models/note_model.dart';
import '../../data/services/note_service.dart';
import 'note_card.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class CategoriesTab extends StatefulWidget {
  final NoteService noteService;
  final List<CategoryModel> categories;
  final List<NoteModel> allNotes;

  // Callback untuk Category Mode (Folder Selection)
  final Function(bool isSelecting) onCategorySelectionModeChanged;

  // Props untuk Note Selection Mode (diteruskan dari Parent)
  final bool isNoteSelectionMode;
  final Set<String> selectedNoteIds;
  final Function(String) onNoteTap;
  final Function(String) onNoteLongPress;

  const CategoriesTab({
    super.key,
    required this.noteService,
    required this.categories,
    required this.allNotes,
    required this.onCategorySelectionModeChanged,
    // Add Note Selection Params
    required this.isNoteSelectionMode,
    required this.selectedNoteIds,
    required this.onNoteTap,
    required this.onNoteLongPress,
  });

  @override
  CategoriesTabState createState() => CategoriesTabState();
}

class CategoriesTabState extends State<CategoriesTab> {
  final Set<String> _expandedCategories = {};

  // State untuk Category Selection (Folder)
  bool _isCategorySelectionMode = false;
  final Set<String> _selectedCategoryIds = {};

  String _getPlainText(String jsonContent) {
    try {
      final doc = quill.Document.fromJson(jsonDecode(jsonContent));
      return doc.toPlainText().trim();
    } catch (e) {
      return jsonContent;
    }
  }

  void _toggleExpand(String categoryId) {
    // 1. Jika sedang Mode Seleksi Kategori (Folder) -> Toggle Select Kategori
    if (_isCategorySelectionMode) {
      _toggleCategorySelection(categoryId);
      return;
    }

    // 2. Jika sedang Mode Seleksi Note -> Disable Expand/Collapse (agar tidak mengganggu)
    //    atau biarkan expand/collapse, tapi tap di note akan select note.
    //    Biasanya, kita biarkan expand/collapse.

    // Normal expand/collapse
    setState(() {
      if (_expandedCategories.contains(categoryId)) {
        _expandedCategories.remove(categoryId);
      } else {
        _expandedCategories.add(categoryId);
      }
    });
  }

  // === LOGIKA SELEKSI KATEGORI (FOLDER) ===

  void _enterCategorySelectionMode(String categoryId) {
    // Jangan masuk mode kategori jika sedang mode note
    if (widget.isNoteSelectionMode) return;

    setState(() {
      _isCategorySelectionMode = true;
      _selectedCategoryIds.clear();
      _selectedCategoryIds.add(categoryId);
    });
    widget.onCategorySelectionModeChanged(true);
  }

  void _toggleCategorySelection(String categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
        if (_selectedCategoryIds.isEmpty) {
          exitSelectionMode();
        }
      } else {
        _selectedCategoryIds.add(categoryId);
      }
    });
  }

  void selectAll() {
    final validCategories = widget.categories
        .where((c) => c.id != 'all' && c.id != 'bookmarks')
        .map((c) => c.id)
        .toList();

    setState(() {
      if (_selectedCategoryIds.length == validCategories.length) {
        _selectedCategoryIds.clear();
      } else {
        _selectedCategoryIds.addAll(validCategories);
      }
    });
  }

  void exitSelectionMode() {
    setState(() {
      _isCategorySelectionMode = false;
      _selectedCategoryIds.clear();
    });
    widget.onCategorySelectionModeChanged(false);
  }

  bool get isSelectionFavorite {
    if (_selectedCategoryIds.isEmpty) return false;
    final selectedCats = widget.categories.where((c) => _selectedCategoryIds.contains(c.id));
    return selectedCats.every((c) => c.isFavorite);
  }

  // --- ACTIONS CATEGORY ---

  void handleEdit() {
    if (_selectedCategoryIds.length != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select exactly one category to edit')),
      );
      return;
    }
    final categoryId = _selectedCategoryIds.first;
    final category = widget.categories.firstWhere((c) => c.id == categoryId);

    showDialog(
      context: context,
      builder: (ctx) => _RenameCategoryDialog(
        initialName: category.name,
        onSave: (newName) async {
          await widget.noteService.updateCategory(
            category.copyWith(name: newName),
          );
          exitSelectionMode();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Category renamed to "$newName"')),
            );
          }
        },
      ),
    );
  }

  void handleToggleFavorite() async {
    if (_selectedCategoryIds.isEmpty) return;
    final areAllFav = isSelectionFavorite;
    for (var id in _selectedCategoryIds) {
      final cat = widget.categories.firstWhere((c) => c.id == id);
      if (cat.isFavorite == areAllFav) {
        await widget.noteService.toggleCategoryFavorite(id, cat.isFavorite);
      }
    }
    exitSelectionMode();
  }

  void handleDelete() {
    if (_selectedCategoryIds.isEmpty) return;
    final count = _selectedCategoryIds.length;
    showIOSDialog(
      context: context,
      title: 'Delete Categories',
      message: 'Delete $count categories?\nNotes inside will be moved to "Uncategorized".',
      confirmText: 'Delete',
      confirmTextColor: const Color(0xFFFF453A),
      onConfirm: () async {
        for (var id in _selectedCategoryIds) {
          await widget.noteService.deleteCategory(id);
        }
        exitSelectionMode();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Categories deleted')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayCategories = widget.categories
        .where((c) => c.id != 'all' && c.id != 'bookmarks')
        .toList();

    if (displayCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No categories yet',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return PopScope(
      canPop: !_isCategorySelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isCategorySelectionMode) {
          exitSelectionMode();
        }
      },
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 120),
        itemCount: displayCategories.length,
        itemBuilder: (context, index) {
          final category = displayCategories[index];
          final notes = widget.allNotes.where((n) => n.categoryId == category.id).toList();
          final isSelected = _selectedCategoryIds.contains(category.id);

          return _CategoryItem(
            key: ValueKey('${category.id}_${category.isFavorite}_$isSelected'),
            category: category,
            noteCount: notes.length,
            isExpanded: _expandedCategories.contains(category.id),
            isSelected: isSelected, // Status seleksi kategori
            isCategorySelectionMode: _isCategorySelectionMode,
            notes: notes,

            // Interaction Kategori
            onTap: () => _toggleExpand(category.id),
            onLongPress: () {
              if (!_isCategorySelectionMode) _enterCategorySelectionMode(category.id);
            },

            noteService: widget.noteService,
            getPlainText: _getPlainText,

            // Props Seleksi Notes (Diteruskan ke NoteCard)
            isNoteSelectionMode: widget.isNoteSelectionMode,
            selectedNoteIds: widget.selectedNoteIds,
            onNoteTap: widget.onNoteTap,
            onNoteLongPress: widget.onNoteLongPress,
          );
        },
      ),
    );
  }
}

class _CategoryItem extends StatefulWidget {
  final CategoryModel category;
  final int noteCount;
  final bool isExpanded;
  final bool isSelected; // Apakah kategori ini dipilih?
  final bool isCategorySelectionMode; // Apakah sedang mode pilih kategori?
  final List<NoteModel> notes;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final NoteService noteService;
  final String Function(String) getPlainText;

  // Note Selection Props
  final bool isNoteSelectionMode;
  final Set<String> selectedNoteIds;
  final Function(String) onNoteTap;
  final Function(String) onNoteLongPress;

  const _CategoryItem({
    super.key,
    required this.category,
    required this.noteCount,
    required this.isExpanded,
    required this.isSelected,
    required this.isCategorySelectionMode,
    required this.notes,
    required this.onTap,
    required this.onLongPress,
    required this.noteService,
    required this.getPlainText,
    // Params Note Selection
    required this.isNoteSelectionMode,
    required this.selectedNoteIds,
    required this.onNoteTap,
    required this.onNoteLongPress,
  });

  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.category.isFavorite;
  }

  @override
  void didUpdateWidget(_CategoryItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category.isFavorite != widget.category.isFavorite) {
      setState(() {
        _isFavorite = widget.category.isFavorite;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    // Disable favorite tap on category card when in ANY selection mode
    if (widget.isCategorySelectionMode || widget.isNoteSelectionMode) return;

    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      await widget.noteService.toggleCategoryFavorite(
        widget.category.id,
        widget.category.isFavorite,
      );
    } catch (e) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color borderPink = Color(0xFFD732A8);
    const Color selectedGrey = Color(0xFFBABABA);
    const Color checkCircleColor = Color(0xFF777777);
    const Color outlineGrey = Color(0xFF777777);

    // Kategori tidak bisa di-expand jika sedang mode seleksi kategori (agar user fokus milih folder)
    // TAPI harus tetap bisa di-expand jika sedang mode seleksi NOTE (agar user bisa cari note di folder lain)
    final bool showNotes = widget.isExpanded;

    return Column(
      children: [
        GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
            height: 50,
            decoration: BoxDecoration(
              color: widget.isSelected ? selectedGrey : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: widget.isSelected ? selectedGrey : borderPink,
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.category.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // VISUAL KATEGORI (Centang atau Count/Fav)
                  if (widget.isSelected) ...[
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: checkCircleColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.check, size: 16, color: Colors.white),
                      ),
                    ),
                  ] else ...[
                    if (widget.noteCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Text(
                          widget.noteCount.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _toggleFavorite,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : outlineGrey,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // GRID NOTES DI DALAM KATEGORI
        // Disembunyikan jika mode seleksi Kategori aktif (agar UI bersih)
        // Tampil jika Expanded (baik mode normal maupun mode seleksi note)
        if (!widget.isCategorySelectionMode)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: widget.notes.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: widget.notes.length,
                itemBuilder: (context, index) {
                  final note = widget.notes[index];
                  final isNoteSelected = widget.selectedNoteIds.contains(note.id);

                  return NoteCard(
                    title: note.title,
                    content: widget.getPlainText(note.content),
                    date: note.formattedDate,
                    color: Color(note.color),
                    isFavorite: note.isFavorite,
                    // LOGIKA SELEKSI NOTE
                    isSelected: widget.isNoteSelectionMode && isNoteSelected,
                    onTap: () => widget.onNoteTap(note.id),
                    onLongPress: () => widget.onNoteLongPress(note.id),
                    onFavoriteTap: () {
                      // Jika mode seleksi aktif, tap love mungkin bisa select note atau toggle fav?
                      // Biasanya di mode seleksi, tap love disabled atau select note.
                      // Kita disable toggle fav single saat mode seleksi.
                      if (!widget.isNoteSelectionMode) {
                        // Panggil callback parent (tapi disini kita butuh akses ke _noteService toggle manual atau callback)
                        // Karena CategoriesTab tidak punya callback onToggleFavoriteNote, kita panggil service langsung atau biarkan.
                        // NoteService bisa diakses via widget.noteService
                        widget.noteService.toggleFavorite(note.id, note.isFavorite);
                      } else {
                        widget.onNoteTap(note.id); // Select note instead
                      }
                    },
                  );
                },
              ),
            )
                : Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                "No notes in this category",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
            ),
            crossFadeState: showNotes ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
      ],
    );
  }
}
// Widget Navbar khusus untuk Kategori (Public agar bisa dipakai NotesMainPage)
class CategorySelectionActionBar extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;
  final bool isSelectedFavorite;

  const CategorySelectionActionBar({
    super.key,
    required this.onEdit,
    required this.onFavorite,
    required this.onDelete,
    required this.isSelectedFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(vertical: 10),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionItem(
            icon: Icons.edit_outlined,
            label: 'Edit',
            onTap: onEdit,
          ),
          _ActionItem(
            icon: isSelectedFavorite ? Icons.favorite : Icons.favorite_border,
            iconColor: isSelectedFavorite ? Colors.red : Colors.black,
            label: 'Favorite',
            onTap: onFavorite,
          ),
          _ActionItem(
            icon: Icons.delete_outline,
            label: 'Delete',
            iconColor: const Color(0xFFD4183D),
            textColor: const Color(0xFFD4183D),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = Colors.black,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dialog Rename Category Menggunakan IOSDialog
class _RenameCategoryDialog extends StatefulWidget {
  final String initialName;
  final Function(String) onSave;

  const _RenameCategoryDialog({
    required this.initialName,
    required this.onSave,
  });

  @override
  State<_RenameCategoryDialog> createState() => _RenameCategoryDialogState();
}

class _RenameCategoryDialogState extends State<_RenameCategoryDialog> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);

    // Auto focus text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _focusNode.requestFocus();
          _controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controller.text.length,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _controller.text.trim();
    if (name.isEmpty || name == widget.initialName) {
      Navigator.pop(context);
      return;
    }
    _focusNode.unfocus();
    setState(() => _isLoading = true);

    try {
      await widget.onSave(name);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IOSDialog(
      title: 'Rename Category',
      confirmText: 'Save',
      cancelText: 'Cancel',
      confirmTextColor: const Color(0xFF007AFF),
      isLoading: _isLoading,
      autoDismiss: false, // Kita handle dismiss manual setelah save
      onConfirm: _handleSave,
      onCancel: () {
        _focusNode.unfocus();
      },
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF007AFF)),
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Category Name',
            hintStyle: GoogleFonts.poppins(
              color: const Color(0xFFC7C7CC),
              fontSize: 14,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => _handleSave(),
        ),
      ),
    );
  }
}