import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/todo_model.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mendapatkan referensi koleksi khusus untuk user yang sedang login
  CollectionReference get _todosCollection {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return _firestore.collection('users').doc(user.uid).collection('todos');
  }

  // Mendapatkan referensi koleksi notifications
  CollectionReference get _notificationsCollection {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return _firestore.collection('users').doc(user.uid).collection('notifications');
  }

  // 1. CREATE: Tambah Task Baru
  Future<void> addTodo(String title, String category, DateTime deadline) async {
    await _todosCollection.add({
      'title': title,
      'category': category,
      'deadline': Timestamp.fromDate(deadline),
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 2. READ: Mengambil Data secara Realtime (Stream)
  Stream<List<TodoModel>> getTodosStream() {
    return _todosCollection
        .orderBy('deadline', descending: false) // Urutkan dari deadline terdekat
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TodoModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 3. UPDATE: Mengubah Status Selesai/Belum
  Future<void> toggleTodoStatus(String id, bool currentStatus) async {
    // Update status
    await _todosCollection.doc(id).update({
      'isCompleted': !currentStatus,
    });

    // Jika task selesai (dari belum selesai menjadi selesai), buat notifikasi
    if (!currentStatus) {
      // Get task details
      DocumentSnapshot todoDoc = await _todosCollection.doc(id).get();
      if (todoDoc.exists) {
        Map<String, dynamic> todoData = todoDoc.data() as Map<String, dynamic>;
        String taskTitle = todoData['title'] ?? 'Task';

        // Create achievement notification
        await _createCompletionNotification(taskTitle);
      }
    }
  }

  // Helper: Create notification when task is completed
  Future<void> _createCompletionNotification(String taskTitle) async {
    try {
      // Check if notification already exists
      QuerySnapshot existing = await _notificationsCollection
          .where('type', isEqualTo: 'achievement')
          .where('description', isEqualTo: 'Great job! You completed "$taskTitle"')
          .get();

      if (existing.docs.isEmpty) {
        await _notificationsCollection.add({
          'title': 'Task Completed! 🎉',
          'description': 'Great job! You completed "$taskTitle"',
          'timestamp': Timestamp.now(),
          'isRead': false,
          'type': 'achievement',
        });
      }
    } catch (e) {
      print('Error creating completion notification: $e');
    }
  }

  // 4. DELETE: Menghapus Task
  Future<void> deleteTodo(String id) async {
    await _todosCollection.doc(id).delete();
  }
}