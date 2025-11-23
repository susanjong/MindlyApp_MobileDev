import 'package:flutter/material.dart';
import '../widgets/task_item.dart';

class AllCategoryScreen extends StatefulWidget {
  const AllCategoryScreen({Key? key}) : super(key: key);

  @override
  State<AllCategoryScreen> createState() => _AllCategoryScreenState();
}

class _AllCategoryScreenState extends State<AllCategoryScreen> {
  final List<List<Color>> availableGradients = [
    [const Color(0xFFBEE973), const Color(0xFFD9D9D9)], // Hijau
    [const Color(0xFF93B7D9), const Color(0xFFD9D9D9)], // Biru
    [const Color(0xFFE2A8D3), const Color(0xFFFFF4FD)], // Pink
  ];

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'PKM 2025',
      'gradientIndex': 0,
      'taskCount': 3,
      'completedCount': 1,
    },
    {
      'name': 'semester 5',
      'gradientIndex': 1,
      'taskCount': 3,
      'completedCount': 1,
    },
    {
      'name': 'Internship',
      'gradientIndex': 2,
      'taskCount': 2,
      'completedCount': 0,
    },
  ];

  final List<Map<String, dynamic>> uncategorizedTasks = [
    {
      'time': '9:50 PM',
      'title': 'Projek Pemmob',
      'date': '01',
      'month': 'NOV',
      'completed': false,
    },
    {
      'time': '4:50 PM',
      'title': 'Diskusi project',
      'date': '01',
      'month': 'JAN',
      'completed': false,
    },
    {
      'time': '4:50 PM',
      'title': 'Beli sayur',
      'date': '01',
      'month': 'JAN',
      'completed': true,
    },
  ];

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
        title: const Text(
          'All Category',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Cards Section
            // Tinggi dikurangi sedikit agar pas dengan rasio gambar (sebelumnya 120)
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryCard(
                    categories[index]['name'],
                    categories[index]['taskCount'],
                    categories[index]['completedCount'],
                    categories[index]['gradientIndex'],
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // Uncategorized Task Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Uncategorized Task',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Task List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: uncategorizedTasks.length,
              itemBuilder: (context, index) {
                return TaskItem(
                  task: uncategorizedTasks[index],
                  onToggle: () {
                    setState(() {
                      bool current = uncategorizedTasks[index]['completed'] ?? false;
                      uncategorizedTasks[index]['completed'] = !current;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12, right: 8),
        child: FloatingActionButton.extended(
          onPressed: _showAddCategoryDialog,
          backgroundColor: const Color(0xFFD732A8),
          icon: const Icon(Icons.add, color: Colors.white, size: 22),
          label: const Text(
            'Add new category',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          elevation: 4,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildCategoryCard(String name, int taskCount, int completedCount, int gradientIndex) {
    final gradient = availableGradients[gradientIndex % availableGradients.length];

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(24), // Sudut lebih membulat
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Memisahkan bagian atas dan bawah
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Category
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16, // Font sedikit lebih besar
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Badge Completed (Pill Shape)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4), // Transparan putih
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedCount Completed',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$taskCount Tasks',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // Menu Icon (Titik tiga)
              const Icon(
                Icons.more_horiz,
                size: 24,
                color: Colors.black87,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController nameController = TextEditingController();
    int selectedGradientIndex = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(70)),
              title: const Text('Add New Category', style: TextStyle(fontWeight: FontWeight.w600)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Category name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Choose color:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [0, 1, 2].map((idx) => _buildGradientOption(idx, selectedGradientIndex, (val) => setState(() => selectedGradientIndex = val))).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      this.setState(() {
                        categories.add({
                          'name': nameController.text.trim(),
                          'gradientIndex': selectedGradientIndex,
                          'taskCount': 0,
                          'completedCount': 0,
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD732A8)),
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildGradientOption(int index, int selectedIndex, Function(int) onTap) {
    final isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 50, height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: availableGradients[index]),
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.black) : null,
      ),
    );
  }
}