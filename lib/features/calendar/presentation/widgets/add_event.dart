import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notesapp/core/widgets/dialog/input_category_dialog.dart';
import 'package:notesapp/features/calendar/data/models/event_model.dart';
import 'package:notesapp/features/calendar/presentation/widgets/update_repeated_dialog.dart';
import '../../../../core/widgets/dialog/alert_dialog.dart';
import '../../../../core/widgets/others/snackbar.dart';
import '../../../../features/calendar/data/services/category_service.dart';
import '../../../../features/calendar/data/services/event_service.dart';

// Bottom Sheet untuk Menambah atau Mengedit Event Kalender
class AddEventBottomSheet extends StatefulWidget {
  final Event? eventToEdit;
  const AddEventBottomSheet({super.key, this.eventToEdit});

  @override
  State<AddEventBottomSheet> createState() => _AddEventBottomSheetState();
}

class _AddEventBottomSheetState extends State<AddEventBottomSheet> {
  // Service Instances
  final EventService _eventService = EventService();
  final EventCategoryService _categoryService = EventCategoryService();
  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  // Controllers untuk input teks
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  // State Management
  bool _isLoading = false;
  bool _isEditMode = false;
  bool _isDataPopulated = false; // Mencegah overwrite data saat rebuild

  // State Tanggal & Waktu
  DateTime? _selectedDateObj;
  TimeOfDay? _startTimeObj;
  TimeOfDay? _endTimeObj;

  // State Pilihan Dropdown & Kategori
  String _reminder = '15 minutes before';
  String _repeat = 'Does not repeat';
  String? _selectedCategoryId;
  List<Category> _categories = [];

  // Data Statis untuk Dropdown
  final List<String> _reminderOptions = [
    'None', '5 minutes before', '10 minutes before', '15 minutes before',
    '30 minutes before', '1 hour before', '1 day before'
  ];
  final List<String> _repeatOptions = [
    'Does not repeat', 'Every day', 'Every week', 'Every month', 'Every year'
  ];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.eventToEdit != null;
    _loadCategories();
  }

  // Mengisi data form jika sedang dalam mode edit
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isEditMode && !_isDataPopulated) {
      _populateExistingData();
      _isDataPopulated = true;
    }
  }

  void _populateExistingData() {
    final event = widget.eventToEdit!;
    _eventNameController.text = event.title;
    _noteController.text = event.description;
    _locationController.text = event.location;

    if (_reminderOptions.contains(event.reminder)) _reminder = event.reminder;
    if (_repeatOptions.contains(event.repeat)) _repeat = event.repeat;

    _selectedDateObj = event.startTime;
    _startTimeObj = TimeOfDay.fromDateTime(event.startTime);
    _endTimeObj = TimeOfDay.fromDateTime(event.endTime);
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

  // Mengambil daftar kategori dari Firebase
  void _loadCategories() {
    _categoryService.getCategories(_userId).listen((categoryList) {
      if (mounted) {
        setState(() {
          _categories = categoryList;
          // Set kategori default jika membuat event baru
          if (!_isEditMode && _categories.isNotEmpty && _selectedCategoryId == null) {
            _selectedCategoryId = _categories.first.id;
          }
        });
      }
    });
  }

  // --- LOGIC: Date & Time Picker ---

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateObj ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF5784EB))),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDateObj = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart ? (_startTimeObj ?? TimeOfDay.now()) : (_endTimeObj ?? TimeOfDay.now());
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF5784EB))),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => isStart ? _startTimeObj = picked : _endTimeObj = picked);
    }
  }

  // --- LOGIC: Validasi & Simpan ---

  Future<void> _validateAndSave() async {
    // Validasi input wajib
    if (_eventNameController.text.isEmpty || _selectedDateObj == null ||
        _startTimeObj == null || _endTimeObj == null || _selectedCategoryId == null) {
      _showErrorDialog('Incomplete Fields', 'Please fill in all required fields.');
      return;
    }

    // Gabungkan Tanggal & Waktu
    final startDateTime = DateTime(
      _selectedDateObj!.year, _selectedDateObj!.month, _selectedDateObj!.day,
      _startTimeObj!.hour, _startTimeObj!.minute,
    );
    final endDateTime = DateTime(
      _selectedDateObj!.year, _selectedDateObj!.month, _selectedDateObj!.day,
      _endTimeObj!.hour, _endTimeObj!.minute,
    );

    // Validasi Logika Waktu
    if (endDateTime.isBefore(startDateTime)) {
      _showErrorDialog('Invalid Time', 'End time must be after start time.');
      return;
    }

    final newEventData = Event(
      id: _isEditMode ? widget.eventToEdit!.id : null,
      title: _eventNameController.text,
      description: _noteController.text,
      startTime: startDateTime,
      endTime: endDateTime,
      categoryId: _selectedCategoryId!,
      userId: _userId,
      createdAt: _isEditMode ? widget.eventToEdit!.createdAt : DateTime.now(),
      location: _locationController.text,
      reminder: _reminder,
      repeat: _repeat,
      parentEventId: _isEditMode ? widget.eventToEdit!.parentEventId : null,
    );

    setState(() => _isLoading = true);

    try {
      if (_isEditMode) {
        final originalEvent = widget.eventToEdit!;
        final isRecurring = originalEvent.repeat != 'Does not repeat' || originalEvent.parentEventId != null;

        // Penanganan khusus untuk Event Berulang (Recurring)
        if (isRecurring) {
          FocusScope.of(context).unfocus();
          setState(() => _isLoading = false);

          showUpdateRepeatDialog(
            context: context,
            onConfirm: (UpdateMode mode) async {
              setState(() => _isLoading = true);
              try {
                await _eventService.updateRecurringEvent(
                  userId: _userId,
                  originalEvent: originalEvent,
                  newEvent: newEventData,
                  mode: mode,
                );
                if (mounted) {
                  Navigator.pop(context);
                  Snackbar.success(context, 'Recurring event updated');
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  Snackbar.error(context, 'Failed: $e');
                }
              }
            },
          );
          return;
        } else {
          // Update Event Biasa (Single)
          await _eventService.updateEvent(_userId, newEventData);
          if (mounted) Snackbar.success(context, 'Event updated');
        }
      } else {
        // Buat Event Baru
        await _eventService.addEvent(newEventData);
        if (mounted) Snackbar.success(context, 'Event created');
      }

      if (mounted && _isLoading) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) Snackbar.error(context, 'Failed to save: $e');
    } finally {
      if (mounted && _isLoading) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String title, String content) {
    showIOSDialog(context: context, title: title, message: content, confirmText: "OK", singleButton: true, onConfirm: () {});
  }

  @override
  Widget build(BuildContext context) {
    // Pengaturan Layout Responsif
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isTablet = screenWidth > 600;

    // Membatasi tinggi sheet agar tidak tertutup keyboard
    final double maxHeight = (screenHeight * 0.9) - keyboardHeight;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 600 : double.infinity,
            maxHeight: maxHeight,
          ),
          child: Container(
            margin: EdgeInsets.only(
              top: keyboardHeight > 0 ? 8 : 24,
              bottom: keyboardHeight > 0 ? 8 : 24,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFCFC),
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(32),
                bottom: isTablet ? const Radius.circular(32) : Radius.zero,
              ),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Sheet (Judul & Tombol Tutup)
                _EventHeader(isEditMode: _isEditMode),

                // Konten Form Scrollable
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.symmetric(horizontal: 17),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _EventInputFields(
                          nameController: _eventNameController,
                          locationController: _locationController,
                          noteController: _noteController,
                          isTablet: isTablet,
                        ),
                        const SizedBox(height: 14),

                        _EventDateTime(
                          dateStr: _selectedDateObj != null
                              ? DateFormat('dd/MM/yyyy').format(_selectedDateObj!)
                              : '',
                          startTimeStr: _startTimeObj?.format(context) ?? '',
                          endTimeStr: _endTimeObj?.format(context) ?? '',
                          onDateTap: _pickDate,
                          onStartTimeTap: () => _pickTime(true),
                          onEndTimeTap: () => _pickTime(false),
                        ),
                        const SizedBox(height: 14),

                        _EventOptions(
                          reminder: _reminder,
                          repeat: _repeat,
                          reminderOptions: _reminderOptions,
                          repeatOptions: _repeatOptions,
                          onReminderChanged: (val) => setState(() => _reminder = val),
                          onRepeatChanged: (val) => setState(() => _repeat = val),
                        ),
                        const SizedBox(height: 17),

                        // Selektor Kategori (Add & Delete)
                        _EventCategory(
                          categories: _categories,
                          selectedId: _selectedCategoryId,
                          onCategorySelected: (id) => setState(() => _selectedCategoryId = id),

                          onAddCategory: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => InputCategoryDialog(
                                title: "New Event Category",
                                hintText: "Meeting, Birthday, etc.",
                                onSave: (name) async {
                                  try {
                                    final newId = await _categoryService.addCategory(
                                      name: name,
                                      userId: _userId,
                                    );
                                    if (mounted) {
                                      setState(() => _selectedCategoryId = newId);
                                    }
                                  } catch (e) {
                                    // Handle error diam-diam atau log
                                  }
                                },
                              ),
                            );
                          },

                          // Fitur Hapus Kategori dengan Long Press
                          onDeleteCategory: (id, name) {
                            showIOSDialog(
                              context: context,
                              title: "Delete Category",
                              message: "Are you sure you want to delete '$name'?\nExisting events will keep their color.",
                              confirmText: "Delete",
                              confirmTextColor: const Color(0xFFFF453A),
                              onConfirm: () async {
                                try {
                                  await _categoryService.deleteCategory(_userId, id);

                                  // Reset seleksi jika kategori yang dihapus sedang dipilih
                                  if (_selectedCategoryId == id) {
                                    setState(() {
                                      _selectedCategoryId = null;
                                    });
                                  }

                                  if (mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Category deleted')),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        _EventSaveButton(
                          isLoading: _isLoading,
                          isEditMode: _isEditMode,
                          onTap: _validateAndSave,
                        ),
                        const SizedBox(height: 30),
                      ],
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

// Widget untuk Header Sheet
class _EventHeader extends StatelessWidget {
  final bool isEditMode;
  const _EventHeader({required this.isEditMode});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: 80, height: 3,
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 24),
              Text(isEditMode ? 'Edit Event' : 'Add New Event', style: GoogleFonts.poppins(color: const Color(0xFF222B45), fontSize: 16, fontWeight: FontWeight.w600)),
              GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, size: 24, color: Color(0xFF222B45))),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget untuk Input Field (Nama, Lokasi, Catatan)
class _EventInputFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController locationController;
  final TextEditingController noteController;
  final bool isTablet;

  const _EventInputFields({
    required this.nameController,
    required this.locationController,
    required this.noteController,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final nameField = _buildTextField(controller: nameController, hint: 'Event name*', isRequired: true);
    final locField = _buildLocationField(locationController);

    return Column(
      children: [
        if (isTablet)
          Row(children: [Expanded(child: nameField), const SizedBox(width: 16), Expanded(child: locField)])
        else ...[
          nameField, const SizedBox(height: 14), locField,
        ],
        const SizedBox(height: 14),
        _buildTextField(controller: noteController, hint: 'Type the note here...', maxLines: 3, height: 70),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, bool isRequired = false, int maxLines = 1, double? height}) {
    return Container(
      height: height ?? 50,
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD1D1D1)), borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      child: TextField(
        controller: controller, maxLines: maxLines,
        style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF222B45)),
        decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.poppins(color: const Color(0xFF8F9BB3), fontSize: 15), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
      ),
    );
  }

  Widget _buildLocationField(TextEditingController controller) {
    return Container(
      height: 50,
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD1D1D1)), borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 20, color: Color(0xFF8F9BB3)),
          const SizedBox(width: 10),
          Expanded(child: TextField(controller: controller, style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF222B45)), decoration: InputDecoration(hintText: 'Location (Optional)', hintStyle: GoogleFonts.poppins(color: const Color(0xFF8F9BB3), fontSize: 15), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))),
        ],
      ),
    );
  }
}

// Widget untuk Picker Tanggal & Waktu
class _EventDateTime extends StatelessWidget {
  final String dateStr;
  final String startTimeStr;
  final String endTimeStr;
  final VoidCallback onDateTap;
  final VoidCallback onStartTimeTap;
  final VoidCallback onEndTimeTap;

  const _EventDateTime({
    required this.dateStr, required this.startTimeStr, required this.endTimeStr,
    required this.onDateTap, required this.onStartTimeTap, required this.onEndTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPickerBox(icon: Icons.calendar_today_outlined, text: dateStr.isEmpty ? 'Date' : dateStr, onTap: onDateTap),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _buildPickerBox(icon: Icons.access_time_outlined, text: startTimeStr.isEmpty ? 'Start time' : startTimeStr, onTap: onStartTimeTap)),
            const SizedBox(width: 18),
            Expanded(child: _buildPickerBox(icon: Icons.access_time_outlined, text: endTimeStr.isEmpty ? 'End time' : endTimeStr, onTap: onEndTimeTap)),
          ],
        ),
      ],
    );
  }

  Widget _buildPickerBox({required IconData icon, required String text, required VoidCallback onTap}) {
    final isPlaceholder = text == 'Date' || text.contains('time');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD1D1D1)), borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [Icon(icon, size: 18, color: const Color(0xFF8F9BB3)), const SizedBox(width: 10), Text(text, style: GoogleFonts.poppins(color: isPlaceholder ? const Color(0xFF8F9BB3) : const Color(0xFF222B45)))]),
      ),
    );
  }
}

// Widget untuk Opsi Reminder & Repeat
class _EventOptions extends StatelessWidget {
  final String reminder;
  final String repeat;
  final List<String> reminderOptions;
  final List<String> repeatOptions;
  final ValueChanged<String> onReminderChanged;
  final ValueChanged<String> onRepeatChanged;

  const _EventOptions({
    required this.reminder, required this.repeat,
    required this.reminderOptions, required this.repeatOptions,
    required this.onReminderChanged, required this.onRepeatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reminder', style: GoogleFonts.poppins(color: const Color(0xFF131313), fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        _buildDropdown(context, reminder, reminderOptions, Icons.notifications_outlined, onReminderChanged),
        const SizedBox(height: 17),
        Text('Repeat', style: GoogleFonts.poppins(color: const Color(0xFF131313), fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        _buildDropdown(context, repeat, repeatOptions, Icons.repeat_outlined, onRepeatChanged),
      ],
    );
  }

  Widget _buildDropdown(BuildContext context, String value, List<String> options, IconData icon, ValueChanged<String> onChanged) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
          builder: (ctx) => Container(
            decoration: const BoxDecoration(color: Color(0xFFFCFCFC), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 10),
              ...options.map((opt) => ListTile(
                title: Text(opt, style: GoogleFonts.poppins()),
                trailing: value == opt ? const Icon(Icons.check, color: Color(0xFFD732A8)) : null,
                onTap: () { onChanged(opt); Navigator.pop(ctx); },
              )),
              const SizedBox(height: 20),
            ]),
          ),
        );
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD1D1D1)), borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(icon, size: 18, color: const Color(0xFF8F9BB3)), const SizedBox(width: 10), Text(value, style: GoogleFonts.poppins(color: const Color(0xFF222B45), fontSize: 15))]), const Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF8F9BB3))]),
      ),
    );
  }
}

// Widget untuk Pilihan Kategori
class _EventCategory extends StatelessWidget {
  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onAddCategory;
  final Function(String id, String name) onDeleteCategory;

  const _EventCategory({
    required this.categories,
    required this.selectedId,
    required this.onCategorySelected,
    required this.onAddCategory,
    required this.onDeleteCategory,
  });

  Color _getColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Category', style: GoogleFonts.poppins(color: const Color(0xFF222B45), fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...categories.map((cat) {
                final color = _getColor(cat.color);
                final isSelected = selectedId == cat.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => onCategorySelected(cat.id!),
                    onLongPress: () => onDeleteCategory(cat.id!, cat.name), // Fitur hapus kategori
                    child: Container(
                      height: 32, padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(border: Border.all(color: color, width: 1.5), borderRadius: BorderRadius.circular(16), color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent),
                      child: Center(child: Text(cat.name, style: GoogleFonts.poppins(color: color, fontSize: 14, fontWeight: FontWeight.w500))),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Center(child: GestureDetector(onTap: onAddCategory, child: Text('+ Add new', style: GoogleFonts.poppins(color: const Color(0xFFD732A8), fontSize: 14, fontWeight: FontWeight.w500)))),
      ],
    );
  }
}

// Tombol Simpan/Update
class _EventSaveButton extends StatelessWidget {
  final bool isLoading;
  final bool isEditMode;
  final VoidCallback onTap;

  const _EventSaveButton({required this.isLoading, required this.isEditMode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity, height: 50,
        decoration: BoxDecoration(color: const Color(0xFFD732A8), borderRadius: BorderRadius.circular(12)),
        child: Center(child: isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(isEditMode ? 'Update' : 'Create', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600))),
      ),
    );
  }
}