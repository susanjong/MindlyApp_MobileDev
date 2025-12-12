import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/dialog/alert_dialog.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends StatefulWidget {
  final Map<String, dynamic> task; // Data awal (bisa usang)
  final VoidCallback onDelete;

  final Function(String newTitle)? onTitleChanged;
  final Function(String newDescription)? onDescriptionChanged;

  const TaskDetailScreen({
   super.key,
    required this.task,
    required this.onDelete,
    this.onTitleChanged,
    this.onDescriptionChanged,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late FocusNode _titleFocusNode;

  bool _isEditingTitle = false;
  bool _isDescriptionDirty = false;
  bool _isLoading = true; // Loading state saat fetch data terbaru

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data yang dikirim (sebagai placeholder)
    _titleController = TextEditingController(text: widget.task['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.task['description'] ?? '');
    _titleFocusNode = FocusNode();

    // ✅ FETCH DATA TERBARU DARI FIREBASE
    _fetchLatestData();
  }

  // Fungsi untuk mengambil data terbaru single document
  Future<void> _fetchLatestData() async {
    try {
      final String? taskId = widget.task['id'];
      if (taskId == null) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Ambil dokumen terbaru
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('todos')
          .doc(taskId)
          .get();

      if (docSnapshot.exists && mounted) {
        final data = docSnapshot.data();
        if (data != null) {
          // Update controller dengan data server terbaru
          setState(() {
            _titleController.text = data['title'] ?? '';
            _descriptionController.text = data['description'] ?? '';

            // Update widget.task lokal agar sinkron juga
            widget.task['title'] = data['title'];
            widget.task['description'] = data['description'];

            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching latest task data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _saveDescription() {
    if (_isDescriptionDirty) {
      final newDesc = _descriptionController.text.trim();
      widget.task['description'] = newDesc;

      if (widget.onDescriptionChanged != null) {
        widget.onDescriptionChanged!(newDesc);
      }
      _isDescriptionDirty = false;
    }
  }

  void _toggleEditing() {
    setState(() {
      if (_isEditingTitle) {
        final newTitle = _titleController.text.trim();
        setState(() {
          widget.task['title'] = newTitle;
        });

        if (widget.onTitleChanged != null) {
          widget.onTitleChanged!(newTitle);
        }
      }
      _isEditingTitle = !_isEditingTitle;
      if (_isEditingTitle) {
        _titleFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    DateTime? deadline;
    if (widget.task['deadline'] is DateTime) {
      deadline = widget.task['deadline'];
    } else if (widget.task['deadline'] is Timestamp) {
      deadline = (widget.task['deadline'] as Timestamp).toDate();
    }

    // ✅ 2. FORMAT TANGGAL UNTUK TAMPILAN
    String dateText = "No Deadline";
    if (deadline != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final checkDate = DateTime(deadline.year, deadline.month, deadline.day);

      if (checkDate == today) {
        dateText = "Today";
      } else if (checkDate == today.add(const Duration(days: 1))) {
        dateText = "Tomorrow";
      } else {
        // Format contoh: 12 Oct 2025
        dateText = DateFormat('d MMM yyyy').format(deadline);
      }
    }

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        _saveDescription();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              _saveDescription();
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.black),
              onPressed: () {
                showIOSDialog(
                  context: context,
                  title: 'Delete Task',
                  message: 'Are you sure you want to delete "${_titleController.text}"?',
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
                        onSubmitted: (_) => _toggleEditing(),
                      )
                          : Text(
                        // Gunakan controller text agar update realtime terlihat
                        _titleController.text.isEmpty ? 'No Title' : _titleController.text,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
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
                        dateText,
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
                    maxLines: null,
                    controller: _descriptionController,
                    onChanged: (value) {
                      // Tandai perubahan, simpan saat back
                      _isDescriptionDirty = true;
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
      ),
    );
  }
}