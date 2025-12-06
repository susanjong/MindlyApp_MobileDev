import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/dialog/alert_dialog.dart';

class TaskDetailScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  final VoidCallback onDelete;
  // Callback opsional jika ingin menyimpan perubahan ke Firebase nantinya
  final Function(String newTitle)? onTitleChanged;

  const TaskDetailScreen({
    Key? key,
    required this.task,
    required this.onDelete,
    this.onTitleChanged,
  }) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late FocusNode _titleFocusNode;
  bool _isEditingTitle = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.task['description'] ?? '');
    _titleFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      if (_isEditingTitle) {
        // LOGIC SAAT SAVE (Icon Centang diklik)
        // Update title di local map agar UI langsung berubah (optional)
        widget.task['title'] = _titleController.text.trim();

        // Panggil callback untuk simpan ke Database/Parent (jika ada)
        if (widget.onTitleChanged != null) {
          widget.onTitleChanged!(_titleController.text.trim());
        }
      }

      _isEditingTitle = !_isEditingTitle;

      // Otomatis focus ke textfield saat mode edit aktif
      if (_isEditingTitle) {
        _titleFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black),
            onPressed: () {
              showIOSDialog(
                context: context,
                title: 'Delete Task',
                message: 'Are you sure you want to delete "${widget.task['title']}"?',
                confirmText: 'Delete',
                confirmTextColor: const Color(0xFFFF453A),
                onConfirm: () {
                  widget.onDelete();
                  Navigator.pop(context);
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TO DO',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),

              // --- TITLE ROW (EDITABLE) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _isEditingTitle
                    // 1. Mode EDIT: Tampilkan TextField
                        ? TextField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF5784EB)),
                        ),
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      // Simpan saat tombol Enter ditekan keyboard
                      onSubmitted: (_) => _toggleEditing(),
                    )
                    // 2. Mode VIEW: Tampilkan Text biasa
                        : Text(
                      widget.task['title'] ?? 'No Title',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Tombol Toggle Edit/Save
                  IconButton(
                    icon: Icon(
                      _isEditingTitle ? Icons.check_circle : Icons.edit_outlined,
                      size: 24,
                      color: _isEditingTitle ? const Color(0xFF5784EB) : Colors.black,
                    ),
                    onPressed: _toggleEditing,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Date & Time Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5784EB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Today',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.task['time'] ?? '',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Description Header
              Row(
                children: [
                  const Icon(Icons.subject, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Description',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Description Input Box
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFB74D),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: TextField(
                  maxLines: null, // Allow multiline
                  controller: _descriptionController,
                  onChanged: (value) {
                    // Update local map real-time saat user mengetik
                    widget.task['description'] = value;
                  },
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Add description...',
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