import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notesapp/features/calendar/data/model/event_model.dart';
import '../../../../features/calendar/data/services/category_service.dart';
import '../../../../features/calendar/data/services/event_service.dart';

class AddEventBottomSheet extends StatefulWidget {
  final Event? eventToEdit; // Parameter untuk mode edit

  const AddEventBottomSheet({super.key, this.eventToEdit});

  @override
  State<AddEventBottomSheet> createState() => _AddEventBottomSheetState();
}

class _AddEventBottomSheetState extends State<AddEventBottomSheet> {
  // Services
  final EventService _eventService = EventService();
  final CategoryService _categoryService = CategoryService();
  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  // Controllers
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  // State Data
  bool _isLoading = false;
  bool _isEditMode = false;
  bool _isDataPopulated = false; // Flag untuk memastikan data hanya diisi sekali

  // Date & Time State
  DateTime? _selectedDateObj;
  TimeOfDay? _startTimeObj;
  TimeOfDay? _endTimeObj;

  // Display Strings
  String _selectedDateStr = '';
  String _startTimeStr = '';
  String _endTimeStr = '';

  // Dropdown Values
  String _reminder = '15 minutes before';
  String _repeat = 'Does not repeat';
  String? _selectedCategoryId;

  // Data Lists
  List<Category> _categories = [];

  final List<String> _reminderOptions = [
    'None', '5 minutes before', '10 minutes before', '15 minutes before',
    '30 minutes before', '1 hour before', '1 day before',
  ];

  final List<String> _repeatOptions = [
    'Does not repeat', 'Every day', 'Every week', 'Every month', 'Every year',
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.eventToEdit != null;
    _loadCategories();
    // JANGAN panggil _populateExistingData() di sini karena butuh context
  }

  // PERBAIKAN UTAMA ADA DI SINI
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Kita jalankan ini saat context sudah siap, dan hanya sekali saja
    if (_isEditMode && !_isDataPopulated) {
      _populateExistingData();
      _isDataPopulated = true;
    }
  }

  void _populateExistingData() {
    final event = widget.eventToEdit!;
    _eventNameController.text = event.title;
    _noteController.text = event.description;
    // _locationController.text = event.location; // Jika nanti ada field location

    // Set Date
    _selectedDateObj = event.startTime;
    _selectedDateStr = DateFormat('dd/MM/yyyy').format(event.startTime);

    // Set Time (Menggunakan TimeOfDay.fromDateTime)
    _startTimeObj = TimeOfDay.fromDateTime(event.startTime);
    _startTimeStr = _startTimeObj!.format(context); // Sekarang aman memanggil context

    _endTimeObj = TimeOfDay.fromDateTime(event.endTime);
    _endTimeStr = _endTimeObj!.format(context); // Sekarang aman memanggil context

    _selectedCategoryId = event.categoryId;
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _noteController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  // --- LOGIC: LOAD CATEGORIES ---
  void _loadCategories() {
    _categoryService.getCategories(_userId).listen((categoryList) {
      if (mounted) {
        setState(() {
          _categories = categoryList;
          // Jika mode tambah baru (bukan edit) dan belum ada kategori dipilih
          if (!_isEditMode && _categories.isNotEmpty && _selectedCategoryId == null) {
            _selectedCategoryId = _categories.first.id;
          }
        });
      }
    });
  }

  // --- LOGIC: SAVE EVENT ---
  Future<void> _validateAndSave() async {
    List<String> missingFields = [];
    if (_eventNameController.text.isEmpty) missingFields.add('Event name');
    if (_selectedDateStr.isEmpty) missingFields.add('Date');
    if (_startTimeStr.isEmpty) missingFields.add('Start time');
    if (_endTimeStr.isEmpty) missingFields.add('End time');
    if (_selectedCategoryId == null) missingFields.add('Category');

    if (missingFields.isNotEmpty) {
      _showErrorDialog('Incomplete Fields', 'Please fill in: ${missingFields.join(', ')}');
      return;
    }

    final startDateTime = DateTime(
        _selectedDateObj!.year, _selectedDateObj!.month, _selectedDateObj!.day,
        _startTimeObj!.hour, _startTimeObj!.minute
    );

    final endDateTime = DateTime(
        _selectedDateObj!.year, _selectedDateObj!.month, _selectedDateObj!.day,
        _endTimeObj!.hour, _endTimeObj!.minute
    );

    if (endDateTime.isBefore(startDateTime)) {
      _showErrorDialog('Invalid Time', 'End time must be after start time.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final eventToSave = Event(
        id: _isEditMode ? widget.eventToEdit!.id : null,
        title: _eventNameController.text,
        description: _noteController.text,
        startTime: startDateTime,
        endTime: endDateTime,
        categoryId: _selectedCategoryId!,
        userId: _userId,
        createdAt: _isEditMode ? widget.eventToEdit!.createdAt : DateTime.now(),
      );

      if (_isEditMode) {
        await _eventService.updateEvent(_userId, eventToSave);
      } else {
        await _eventService.addEvent(eventToSave);
      }

      // ✅ REMOVED: Tidak schedule reminder di sini
      // Reminder akan di-trigger manual dari ReminderCard saja
      // Ini mencegah duplikasi notifikasi

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Event updated successfully' : 'Event created successfully'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error', 'Failed to save event: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFCFCFC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFFD4183D))),
        content: Text(content, style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.poppins(color: const Color(0xFFD732A8))),
          ),
        ],
      ),
    );
  }

  // --- LOGIC: ADD CATEGORY ---
  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFCFCFC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add New Category', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        content: TextField(
          controller: _categoryController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Category name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_categoryController.text.isNotEmpty) {
                final randomColor = Colors.primaries[DateTime.now().millisecond % Colors.primaries.length];
                String hexColor = '#${randomColor.toARGB32().toRadixString(16).substring(2)}';

                final newCategory = Category(
                  name: _categoryController.text,
                  color: hexColor,
                  userId: _userId,
                );

                await _categoryService.addCategory(newCategory);
                _categoryController.clear();
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: Color(0xFFD732A8), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- LOGIC: PICKERS ---
  Future<void> _pickTime(bool isStart) async {
    final initialTime = isStart
        ? (_startTimeObj ?? TimeOfDay.now())
        : (_endTimeObj ?? TimeOfDay.now());

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5784EB),
              onSurface: Color(0xFF222B45),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        if (isStart) {
          _startTimeObj = pickedTime;
          _startTimeStr = pickedTime.format(context);
        } else {
          _endTimeObj = pickedTime;
          _endTimeStr = pickedTime.format(context);
        }
      });
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateObj ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5784EB),
              onSurface: Color(0xFF222B45),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDateObj = pickedDate;
        _selectedDateStr = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  // --- WIDGET HELPERS ---

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isRequired = false,
    int maxLines = 1,
    double? height,
  }) {
    return Container(
      height: height ?? 50,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D1D1)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF222B45)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: const Color(0xFF8F9BB3), fontSize: 15),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D1D1)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 20,
            color: Color(0xFF8F9BB3),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _locationController,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: const Color(0xFF222B45),
              ),
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Add location',
                hintStyle: GoogleFonts.poppins(
                  color: const Color(0xFF8F9BB3),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1D1D1)),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: const Color(0xFF8F9BB3)),
                const SizedBox(width: 10),
                Text(value, style: GoogleFonts.poppins(color: const Color(0xFF222B45), fontSize: 15)),
              ],
            ),
            const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF8F9BB3)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _showReminderPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        decoration: const BoxDecoration(
          color: Color(0xFFFCFCFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text('Select Reminder', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              ..._reminderOptions.map((option) => ListTile(
                title: Text(option),
                trailing: _reminder == option ? const Icon(Icons.check, color: Color(0xFFD732A8)) : null,
                onTap: () {
                  setState(() => _reminder = option);
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showRepeatPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        decoration: const BoxDecoration(
          color: Color(0xFFFCFCFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text('Select Repeat', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              ..._repeatOptions.map((option) => ListTile(
                title: Text(option),
                trailing: _repeat == option ? const Icon(Icons.check, color: Color(0xFFD732A8)) : null,
                onTap: () {
                  setState(() => _repeat = option);
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double availableHeight = (screenHeight * 0.88) - keyboardHeight;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        constraints: BoxConstraints(
          minHeight: screenHeight * 0.4,
          maxHeight: availableHeight > 0 ? availableHeight : screenHeight * 0.88,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFCFC),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          border: Border.all(color: Colors.black.withValues(alpha: 0.15), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 80,
              height: 3,
              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(2)),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24),
                  Text(_isEditMode ? 'Edit Event' : 'Add New Event', style: GoogleFonts.poppins(color: const Color(0xFF222B45), fontSize: 20, fontWeight: FontWeight.w600)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 24, color: Color(0xFF222B45)),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Name
                    _buildTextField(controller: _eventNameController, hint: 'Event name*', isRequired: true),
                    const SizedBox(height: 14),

                    // Note
                    _buildTextField(controller: _noteController, hint: 'Type the note here...', maxLines: 3, height: 70),
                    const SizedBox(height: 14),

                    // Date
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD1D1D1)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF8F9BB3)),
                            const SizedBox(width: 10),
                            Text(_selectedDateStr.isEmpty ? 'Date' : _selectedDateStr,
                                style: GoogleFonts.poppins(color: _selectedDateStr.isEmpty ? const Color(0xFF8F9BB3) : const Color(0xFF222B45))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Time
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickTime(true),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD1D1D1)), borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_outlined, size: 18, color: Color(0xFF8F9BB3)),
                                  const SizedBox(width: 10),
                                  Text(_startTimeStr.isEmpty ? 'Start time' : _startTimeStr,
                                      style: GoogleFonts.poppins(color: _startTimeStr.isEmpty ? const Color(0xFF8F9BB3) : const Color(0xFF222B45))),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickTime(false),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD1D1D1)), borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_outlined, size: 18, color: Color(0xFF8F9BB3)),
                                  const SizedBox(width: 10),
                                  Text(_endTimeStr.isEmpty ? 'End time' : _endTimeStr,
                                      style: GoogleFonts.poppins(color: _endTimeStr.isEmpty ? const Color(0xFF8F9BB3) : const Color(0xFF222B45))),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    _buildLocationField(),
                    const SizedBox(height: 14),

                    // Reminder & Repeat
                    Text('Reminder', style: GoogleFonts.poppins(color: const Color(0xFF131313), fontSize: 15, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    _buildDropdownField(value: _reminder, onTap: _showReminderPicker, icon: Icons.notifications_outlined),
                    const SizedBox(height: 17),

                    Text('Repeat', style: GoogleFonts.poppins(color: const Color(0xFF131313), fontSize: 15, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    _buildDropdownField(value: _repeat, onTap: _showRepeatPicker, icon: Icons.repeat_outlined),
                    const SizedBox(height: 17),

                    // Category
                    Text('Select Category', style: GoogleFonts.poppins(color: const Color(0xFF222B45), fontSize: 15, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ..._categories.map((category) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: _buildCategoryChip(
                                label: category.name,
                                color: _getColorFromHex(category.color),
                                isSelected: _selectedCategoryId == category.id,
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryId = category.id;
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: GestureDetector(
                        onTap: _showAddCategoryDialog,
                        child: Text('+ Add new', style: GoogleFonts.poppins(color: const Color(0xFFD732A8), fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Save Button
                    GestureDetector(
                      onTap: _isLoading ? null : _validateAndSave,
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD732A8),
                          borderRadius: BorderRadius.circular(7),
                          boxShadow: [BoxShadow(color: const Color(0xFFD732A8).withValues(alpha:0.3), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(
                            _isEditMode ? 'Update Event' : 'Create Event',
                            style: GoogleFonts.poppins(color: const Color(0xFFF2F2F2), fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}