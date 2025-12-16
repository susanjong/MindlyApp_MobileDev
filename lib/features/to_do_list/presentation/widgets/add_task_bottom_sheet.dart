import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ Import Service & Model
import '../../data/models/category_model.dart';
import '../../data/services/category_service.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>)? onSave;
  final String? initialCategory;
  final bool isCategoryLocked;

  const AddTaskBottomSheet({
    super.key,
    this.onSave,
    this.initialCategory,
    this.isCategoryLocked = false,
  });

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();

  static void show(BuildContext context, {
    Function(Map<String, dynamic>)? onSave,
    String? initialCategory,
    bool isCategoryLocked = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AddTaskBottomSheet(
          onSave: onSave,
          initialCategory: initialCategory,
          isCategoryLocked: isCategoryLocked,
        );
      },
    );
  }
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final CategoryService _categoryService = CategoryService();

  String _selectedDay = 'Day';
  String _selectedMonth = 'Month';
  String _selectedYear = 'Year';
  String? _selectedCategory;

  String _selectedHour = '09';
  String _selectedMinute = '00';

  bool _isFormValid = false;

  int _getMonthNumber(String monthName) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    return months[monthName] ?? 1;
  }

  // ✅ DATA SEMENTARA
  Map<String, dynamic>? _tempNewCategory;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory;
    }

    // Tambahkan listener untuk validasi realtime saat mengetik
    _nameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateForm);
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isNameFilled = _nameController.text.trim().isNotEmpty;
    final isDateFilled = _selectedDay != 'Day' && _selectedMonth != 'Month' && _selectedYear != 'Year';
    final isCategoryFilled = _selectedCategory != null;

    final isValid = isNameFilled && isDateFilled && isCategoryFilled;

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  // ✅ LOGIC SAVE UTAMA
  void _handleSave() async {
    if (!_isFormValid) return; // Mencegah save jika tidak valid

    // 1. Tentukan Kategori Final
    String finalCategory;
    if (widget.isCategoryLocked && widget.initialCategory != null) {
      finalCategory = widget.initialCategory!;
    } else {
      finalCategory = _selectedCategory ?? 'Uncategorized';
    }

    // 2. CEK: Apakah kategori yang dipilih adalah kategori BARU (sementara)?
    if (_tempNewCategory != null && finalCategory == _tempNewCategory!['name']) {
      await _categoryService.addCategory(
          _tempNewCategory!['name'],
          _tempNewCategory!['gradientIndex']
      );
    }

    DateTime? finalDeadline;

    try {
      final int day = int.parse(_selectedDay);
      final int month = _getMonthNumber(_selectedMonth);
      final int year = int.parse(_selectedYear);
      final int hour = int.parse(_selectedHour);
      final int minute = int.parse(_selectedMinute);

      finalDeadline = DateTime(year, month, day, hour, minute);
    } catch (e) {
      debugPrint("Error parsing date: $e");
      finalDeadline = DateTime.now().add(const Duration(hours: 1));
    }

    final taskData = {
      'title': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': finalCategory,
      'deadline': finalDeadline,
      'completed': false,
      'createdAt': DateTime.now(),
    };

    widget.onSave?.call(taskData);
    if (mounted) Navigator.pop(context);
  }

  void _showAddCategoryDialog() async {
    final result = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const _IOSAddCategoryDialogContent();
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _tempNewCategory = result;
        _selectedCategory = result['name'];
        _validateForm(); // Validasi ulang setelah pilih kategori baru
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.black54, fontSize: 16)),
                ),
                TextButton(
                  onPressed: _isFormValid ? _handleSave : null, // Disable jika form tidak valid
                  child: Text(
                    'Save',
                    style: TextStyle(
                        color: _isFormValid ? const Color(0xFF5784EB) : Colors.grey, // Warna abu jika disable
                        fontSize: 16,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('NAME'),
                  const SizedBox(height: 8),
                  _buildTextField(controller: _nameController, hintText: 'Add task name'),

                  const SizedBox(height: 24),
                  _buildLabel('DESCRIPTION (OPTIONAL)'),
                  const SizedBox(height: 8),
                  _buildTextField(controller: _descriptionController, hintText: 'Enter a detail of the task', maxLines: 3),

                  const SizedBox(height: 24),

                  // ==========================================
                  // 1. BAGIAN DEADLINE DATE (Wajib)
                  // ==========================================
                  _buildLabel('DEADLINE DATE'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          value: _selectedDay,
                          items: ['Day', ...List.generate(31, (i) => '${i + 1}')],
                          onChanged: (val) {
                            setState(() => _selectedDay = val!);
                            _validateForm(); // Validasi ulang
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          value: _selectedMonth,
                          items: ['Month', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                          onChanged: (val) {
                            setState(() => _selectedMonth = val!);
                            _validateForm(); // Validasi ulang
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          value: _selectedYear,
                          items: ['Year', '2025', '2026', '2027'],
                          onChanged: (val) {
                            setState(() => _selectedYear = val!);
                            _validateForm(); // Validasi ulang
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ==========================================
                  // 2. BAGIAN TIME (Wajib karena default sudah terisi)
                  // ==========================================
                  _buildLabel('TIME'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          value: _selectedHour,
                          items: List.generate(24, (i) => i.toString().padLeft(2, '0')),
                          onChanged: (val) => setState(() => _selectedHour = val!),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(":", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      Expanded(
                        child: _buildDropdown(
                          value: _selectedMinute,
                          items: List.generate(60, (i) => i.toString().padLeft(2, '0')),
                          onChanged: (val) => setState(() => _selectedMinute = val!),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _buildLabel('CATEGORY'),
                  const SizedBox(height: 8),

                  if (widget.isCategoryLocked && widget.initialCategory != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF5784EB), width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade100,
                      ),
                      child: Text(
                        widget.initialCategory!,
                        style: const TextStyle(color: Colors.black54, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    StreamBuilder<List<CategoryModel>>(
                      stream: _categoryService.getCategoriesStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: LinearProgressIndicator());
                        }

                        final categories = snapshot.data!;
                        List<String> categoryNames = ['Uncategorized'];
                        categoryNames.addAll(categories.map((c) => c.name).toList());

                        if (_tempNewCategory != null) {
                          if (!categoryNames.contains(_tempNewCategory!['name'])) {
                            categoryNames.add(_tempNewCategory!['name']);
                          }
                        }

                        const String addNewOption = '➕ Add New Category';
                        categoryNames.add(addNewOption);

                        // Fallback selection & Auto validation trigger
                        if (_selectedCategory == null || (!categoryNames.contains(_selectedCategory))) {
                          if (widget.initialCategory != null && categoryNames.contains(widget.initialCategory)) {
                            _selectedCategory = widget.initialCategory;
                          } else {
                            _selectedCategory = categoryNames.first;
                          }
                          // Trigger validation karena kategori mungkin baru terisi otomatis
                          WidgetsBinding.instance.addPostFrameCallback((_) => _validateForm());
                        }

                        return _buildDropdown(
                          value: _selectedCategory!,
                          items: categoryNames,
                          onChanged: (val) {
                            if (val == addNewOption) {
                              _showAddCategoryDialog();
                            } else {
                              setState(() => _selectedCategory = val);
                              _validateForm(); // Validasi ulang
                            }
                          },
                        );
                      },
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black54, letterSpacing: 0.5),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF5784EB), width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF5784EB), width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF5784EB), width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          style: const TextStyle(color: Color(0xFF454444), fontSize: 15),
          menuMaxHeight: 300,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(color: Color(0xFF454444), fontSize: 15)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

//  DIALOG ADD CATEGORY (UI Only - Return Data)
class _IOSAddCategoryDialogContent extends StatefulWidget {
  const _IOSAddCategoryDialogContent({super.key});

  @override
  State<_IOSAddCategoryDialogContent> createState() =>
      _IOSAddCategoryDialogContentState();
}

class _IOSAddCategoryDialogContentState extends State<_IOSAddCategoryDialogContent> {
  final TextEditingController _nameController = TextEditingController();

  int _selectedGradientIndex = 0;
  final List<List<Color>> availableGradients = [
    [const Color(0xFFBEE973), const Color(0xFFD9D9D9)],
    [const Color(0xFF93B7D9), const Color(0xFFD9D9D9)],
    [const Color(0xFFE2A8D3), const Color(0xFFFFF4FD)],
  ];

  @override
  Widget build(BuildContext context) {
    const blueColor = Color(0xFF007AFF);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 270,
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                child: Column(
                  children: [
                    Text('Add New Category', textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        controller: _nameController,
                        style: GoogleFonts.poppins(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Category Name',
                          contentPadding: const EdgeInsets.only(bottom: 12, left: 5),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: blueColor, width: 1)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: blueColor, width: 1.5)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(availableGradients.length, (index) {
                        final isSelected = _selectedGradientIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedGradientIndex = index),
                          child: Container(
                            width: 32, height: 32, margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: availableGradients[index], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              shape: BoxShape.circle,
                              border: Border.all(color: isSelected ? Colors.black87 : Colors.black12, width: isSelected ? 2 : 0.5),
                            ),
                            child: isSelected ? const Icon(Icons.check, size: 18, color: Colors.black54) : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: const Color(0xFFE0E0E0)),
              SizedBox(
                height: 45,
                child: Row(
                  children: [
                    Expanded(child: InkWell(onTap: () => Navigator.pop(context), child: Center(child: Text('Cancel', style: GoogleFonts.poppins(color: blueColor, fontSize: 15))))),
                    Container(width: 1, color: const Color(0xFFE0E0E0)),
                    // ✅ TOMBOL ADD (Hanya Return Data)
                    Expanded(child: InkWell(onTap: () {
                      final name = _nameController.text.trim();
                      if (name.isNotEmpty) {
                        // KEMBALIKAN DATA KE PARENT
                        Navigator.pop(context, {
                          'name': name,
                          'gradientIndex': _selectedGradientIndex
                        });
                      }
                    }, child: Center(child: Text('Add', style: GoogleFonts.poppins(color: blueColor, fontSize: 15, fontWeight: FontWeight.w600))))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}