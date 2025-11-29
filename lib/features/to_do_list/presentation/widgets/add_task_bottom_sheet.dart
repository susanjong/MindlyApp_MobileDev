import 'package:flutter/material.dart';
// ✅ Import Model & Service Kategori
import '../../data/models/category_model.dart';
import '../../data/services/category_service.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>)? onSave;

  const AddTaskBottomSheet({
    Key? key,
    this.onSave,
  }) : super(key: key);

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();

  static void show(BuildContext context, {Function(Map<String, dynamic>)? onSave}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AddTaskBottomSheet(onSave: onSave);
      },
    );
  }
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final CategoryService _categoryService = CategoryService(); // ✅ Panggil Service

  String _selectedDay = 'Day';
  String _selectedMonth = 'Month';
  String _selectedYear = 'Year';
  String? _selectedCategory; // Nullable agar bisa handle loading

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    // Validasi input minimal
    if (_nameController.text.trim().isEmpty) return;

    final taskData = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'day': _selectedDay,
      'month': _selectedMonth,
      'year': _selectedYear,
      'category': _selectedCategory ?? 'Uncategorized', // Default jika null
      'completed': false,
    };

    widget.onSave?.call(taskData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
                  onPressed: _handleSave,
                  child: const Text('Save', style: TextStyle(color: Color(0xFF5784EB), fontSize: 16, fontWeight: FontWeight.w600)),
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
                  _buildLabel('DEADLINE'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          value: _selectedDay,
                          items: ['Day', ...List.generate(31, (i) => '${i + 1}')],
                          onChanged: (val) => setState(() => _selectedDay = val!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          value: _selectedMonth,
                          items: ['Month', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                          onChanged: (val) => setState(() => _selectedMonth = val!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          value: _selectedYear,
                          items: ['Year', '2024', '2025', '2026'],
                          onChanged: (val) => setState(() => _selectedYear = val!),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ✅ BAGIAN KATEGORI (Dinamis dari Firebase)
                  _buildLabel('CATEGORY'),
                  const SizedBox(height: 8),

                  StreamBuilder<List<CategoryModel>>(
                    stream: _categoryService.getCategoriesStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: LinearProgressIndicator());
                      }

                      final categories = snapshot.data!;
                      List<String> categoryNames = ['Uncategorized']; // Default option
                      categoryNames.addAll(categories.map((c) => c.name).toList());

                      // Pastikan nilai yang dipilih ada di dalam list (untuk menghindari error dropdown)
                      if (_selectedCategory == null || !categoryNames.contains(_selectedCategory)) {
                        _selectedCategory = categoryNames.first;
                      }

                      return _buildDropdown(
                        value: _selectedCategory!,
                        items: categoryNames,
                        onChanged: (val) {
                          setState(() => _selectedCategory = val);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets (Tidak Berubah)
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