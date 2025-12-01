import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notesapp/core/widgets/dialog/alert_dialog.dart';

class AddEventBottomSheet extends StatefulWidget {
  const AddEventBottomSheet({super.key});

  @override
  State<AddEventBottomSheet> createState() => _AddEventBottomSheetState();
}

class _AddEventBottomSheetState extends State<AddEventBottomSheet> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  String _selectedDate = '';
  String _startTime = '';
  String _endTime = '';
  String _reminder = '15 minutes before';
  String _repeat = 'Does not repeat';

  final List<String> _reminderOptions = [
    'None',
    '5 minutes before',
    '10 minutes before',
    '15 minutes before',
    '30 minutes before',
    '1 hour before',
    '1 day before',
  ];

  final List<String> _repeatOptions = [
    'Does not repeat',
    'Every day',
    'Every week',
    'Every month',
    'Every year',
  ];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Organisasi', 'color': const Color(0xFF004455), 'selected': false},
    {'name': 'Belajar', 'color': const Color(0xFF5683EB), 'selected': false},
  ];

  @override
  void dispose() {
    _eventNameController.dispose();
    _noteController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  // Check if any field is filled
  bool get _hasAnyContent {
    return _eventNameController.text.isNotEmpty ||
        _noteController.text.isNotEmpty ||
        _locationController.text.isNotEmpty ||
        _selectedDate.isNotEmpty ||
        _startTime.isNotEmpty ||
        _endTime.isNotEmpty;
  }

  // Validate all required fields
  void _validateAndSave() {
    List<String> missingFields = [];

    if (_eventNameController.text.isEmpty) {
      missingFields.add('Event name');
    }
    if (_selectedDate.isEmpty) {
      missingFields.add('Date');
    }
    if (_startTime.isEmpty) {
      missingFields.add('Start time');
    }
    if (_endTime.isEmpty) {
      missingFields.add('End time');
    }

    if (missingFields.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFFFCFCFC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFBAE38),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Incomplete Fields',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF222B45),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please fill in the following required fields:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF222B45),
                ),
              ),
              const SizedBox(height: 12),
              ...missingFields.map((field) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 6,
                      color: Color(0xFFD4183D),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      field,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFFD4183D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFD732A8),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // Validate time logic: End time must be after Start time
    if (_startTime.isNotEmpty && _endTime.isNotEmpty) {
      final startTimeParts = _startTime.split(':');
      final endTimeParts = _endTime.split(':');

      int startHour = int.parse(startTimeParts[0].replaceAll(RegExp(r'[^0-9]'), ''));
      int startMinute = int.parse(startTimeParts[1].replaceAll(RegExp(r'[^0-9]'), ''));

      int endHour = int.parse(endTimeParts[0].replaceAll(RegExp(r'[^0-9]'), ''));
      int endMinute = int.parse(endTimeParts[1].replaceAll(RegExp(r'[^0-9]'), ''));

      // Handle AM/PM conversion
      if (_startTime.toLowerCase().contains('pm') && startHour != 12) {
        startHour += 12;
      } else if (_startTime.toLowerCase().contains('am') && startHour == 12) {
        startHour = 0;
      }

      if (_endTime.toLowerCase().contains('pm') && endHour != 12) {
        endHour += 12;
      } else if (_endTime.toLowerCase().contains('am') && endHour == 12) {
        endHour = 0;
      }

      final startTotalMinutes = startHour * 60 + startMinute;
      final endTotalMinutes = endHour * 60 + endMinute;

      if (endTotalMinutes <= startTotalMinutes) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFFFCFCFC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFD4183D),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Invalid Time',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF222B45),
                  ),
                ),
              ],
            ),
            content: Text(
              'End time must be after start time. Please adjust your time selection.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF222B45),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFD732A8),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        );
        return;
      }
    }

    // if all fields are valid, show success snackbar and close
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Success!',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Event has been saved successfully',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }

  void _showReminderPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFCFCFC),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha:0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Reminder',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF222B45),
                ),
              ),
            ),
            ..._reminderOptions.map((option) => ListTile(
              title: Text(
                option,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: const Color(0xFF222B45),
                ),
              ),
              trailing: _reminder == option
                  ? const Icon(Icons.check, color: Color(0xFFD732A8))
                  : null,
              onTap: () {
                setState(() => _reminder = option);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showRepeatPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFCFCFC),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha:0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Repeat',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF222B45),
                ),
              ),
            ),
            ..._repeatOptions.map((option) => ListTile(
              title: Text(
                option,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: const Color(0xFF222B45),
                ),
              ),
              trailing: _repeat == option
                  ? const Icon(Icons.check, color: Color(0xFFD732A8))
                  : null,
              onTap: () {
                setState(() => _repeat = option);
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFCFCFC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Add New Category',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF222B45),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _categoryController,
              autofocus: true,
              style: GoogleFonts.poppins(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Category name',
                hintStyle: GoogleFonts.poppins(
                  color: const Color(0xFF8F9BB3),
                  fontSize: 15,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD1D1D1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD1D1D1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD732A8)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: const Color(0xFF88817E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_categoryController.text.isNotEmpty) {
                setState(() {
                  _categories.add({
                    'name': _categoryController.text,
                    'color': Color((DateTime.now().millisecondsSinceEpoch * 0xFFFFFF).toInt())
                        .withValues(alpha: 1.0),
                    'selected': false,
                  });
                  _categoryController.clear();
                });
                Navigator.pop(context);
              }
            },
            child: Text(
              'Add',
              style: GoogleFonts.poppins(
                color: const Color(0xFFD732A8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: const Color(0xFF222B45),
        ),
        onChanged: (value) {
          setState(() {}); // Trigger rebuild to show/hide delete button
        },
        decoration: InputDecoration(
          hintText: hint,
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
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF5784EB),
                  onSurface: Color(0xFF222B45),
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF8F9BB3),
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() {
            _selectedDate = DateFormat('dd/MM/yyyy').format(date);
          });
        }
      },
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
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Color(0xFF8F9BB3),
                ),
                const SizedBox(width: 10),
                Text(
                  _selectedDate.isEmpty ? 'Date' : _selectedDate,
                  style: GoogleFonts.poppins(
                    color: _selectedDate.isEmpty
                        ? const Color(0xFF8F9BB3)
                        : const Color(0xFF222B45),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required String hint,
    required String value,
    required VoidCallback onTap,
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
                const Icon(
                  Icons.access_time_outlined,
                  size: 18,
                  color: Color(0xFF8F9BB3),
                ),
                const SizedBox(width: 10),
                Text(
                  value.isEmpty ? hint : value,
                  style: GoogleFonts.poppins(
                    color: value.isEmpty
                        ? const Color(0xFF8F9BB3)
                        : const Color(0xFF222B45),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
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
                setState(() {}); // Trigger rebuild to show/hide delete button
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
                Icon(
                  icon,
                  size: 18,
                  color: const Color(0xFF8F9BB3),
                ),
                const SizedBox(width: 10),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF222B45),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: Color(0xFF8F9BB3),
            ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFC),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 80,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                Text(
                  'Add New Event',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF222B45),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    size: 24,
                    color: Color(0xFF222B45),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Name
                  _buildTextField(
                    controller: _eventNameController,
                    hint: 'Event name*',
                    isRequired: true,
                    height: 50,
                  ),

                  const SizedBox(height: 14),

                  // Note
                  _buildTextField(
                    controller: _noteController,
                    hint: 'Type the note here...',
                    maxLines: 3,
                    height: 70,
                  ),

                  const SizedBox(height: 14),

                  // Date
                  _buildDateField(),

                  const SizedBox(height: 14),

                  // Time
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeField(
                          hint: 'Start time',
                          value: _startTime,
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF5784EB),
                                      onSurface: Color(0xFF222B45),
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: const Color(0xFF5784EB),
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (time != null) {
                              setState(() {
                                _startTime = time.format(context);
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _buildTimeField(
                          hint: 'End time',
                          value: _endTime,
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF5784EB),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (time != null) {
                              setState(() {
                                _endTime = time.format(context);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Location
                  _buildLocationField(),

                  const SizedBox(height: 14),

                  // Reminder
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reminder',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF131313),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildDropdownField(
                        value: _reminder,
                        onTap: _showReminderPicker,
                        icon: Icons.notifications_outlined,
                      ),
                    ],
                  ),

                  const SizedBox(height: 17),

                  // Repeat
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repeat',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF131313),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildDropdownField(
                        value: _repeat,
                        onTap: _showRepeatPicker,
                        icon: Icons.repeat_outlined,
                      ),
                    ],
                  ),

                  const SizedBox(height: 17),

                  // Category - HORIZONTAL SCROLL
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Category',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF222B45),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ..._categories.map((category) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: _buildCategoryChip(
                                  label: category['name'],
                                  color: category['color'],
                                  isSelected: category['selected'],
                                  onTap: () {
                                    setState(() {
                                      category['selected'] = !category['selected'];
                                    });
                                  },
                                ),
                              );
                            })
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: GestureDetector(
                          onTap: _showAddCategoryDialog,
                          child: Text(
                            '+ Add new',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFD732A8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Create/Save Button
                  GestureDetector(
                    onTap: () {
                      if (_hasAnyContent) {
                        _validateAndSave();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD732A8),
                        borderRadius: BorderRadius.circular(7),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD732A8).withValues(alpha:0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _hasAnyContent ? 'Save Changes' : 'Create Event',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFF2F2F2),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // delete event button
                  if (_hasAnyContent) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        showIOSDialog(
                          context: context,
                          title: "Delete Event",
                          message: "Are you sure you want to delete this event?",
                          cancelText: "Cancel",
                          confirmText: "Delete",
                          confirmTextColor: const Color(0xFFD4183D),
                          onCancel: () {},
                          onConfirm: () {
                            // Clear all fields
                            setState(() {
                              _eventNameController.clear();
                              _noteController.clear();
                              _locationController.clear();
                              _selectedDate = '';
                              _startTime = '';
                              _endTime = '';
                            });
                          },
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha:0.80),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFD4183D).withValues(alpha:0.3),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Delete Event',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFD4183D),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.38,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}