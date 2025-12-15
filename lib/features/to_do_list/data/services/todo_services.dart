// todo_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/todo_model.dart';
import 'package:notesapp/features/home/data/services/notification_service.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  CollectionReference get _todosCollection {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return _firestore.collection('users').doc(user.uid).collection('todos');
  }

  // ✅ CREATE: Tambah Task Baru dengan notifikasi
  Future<void> addTodo(String title, String category, DateTime deadline, String description) async {
    final docRef = await _todosCollection.add({
      'title': title,
      'description': description,
      'category': category,
      'deadline': Timestamp.fromDate(deadline),
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // ✅ Create notification untuk task baru
    await _notificationService.createNotification(
      title: '✅ New Task Created',
      description: 'Task "$title" has been added to your list',
      type: 'achievement',
      priority: 'medium',
      relatedTaskId: docRef.id,
    );

    // ✅ Check apakah deadline dalam 24 jam
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.inHours <= 24 && difference.inHours > 0) {
      await _notificationService.createNotification(
        title: '⏰ Upcoming Deadline',
        description: 'Task "$title" is due soon!',
        type: 'deadline',
        priority: 'high',
        relatedTaskId: docRef.id,
      );
    }
  }

  // ✅ READ: Mengambil Data secara Realtime (Stream)
  Stream<List<TodoModel>> getTodosStream() {
    return _todosCollection
        .orderBy('deadline', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TodoModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // ✅ UPDATE: Mengubah Status Selesai/Belum dengan notifikasi
  Future<void> toggleTodoStatus(String id, bool currentStatus) async {
    await _todosCollection.doc(id).update({
      'isCompleted': !currentStatus,
    });

    // ✅ Jika task selesai, buat notifikasi achievement
    if (currentStatus == false) {
      final taskDoc = await _todosCollection.doc(id).get();
      if (taskDoc.exists) {
        final data = taskDoc.data() as Map<String, dynamic>;
        final title = data['title'] ?? 'Task';
        final deadline = (data['deadline'] as Timestamp).toDate();
        final now = DateTime.now();

        // Cek apakah completed AFTER deadline (overdue completion)
        if (now.isAfter(deadline)) {
          await _notificationService.createNotification(
            title: '🎉 Overdue Task Completed!',
            description: 'You completed "$title" even though it was overdue. Better late than never!',
            type: 'achievement',
            priority: 'high',
            relatedTaskId: id,
          );
        } else {
          await _notificationService.createNotification(
            title: '🎉 Task Completed!',
            description: 'Great job! You completed "$title"',
            type: 'achievement',
            priority: 'medium',
            relatedTaskId: id,
          );
        }
      }
    }
  }

  Future<void> updateTaskTitle(String id, String newTitle) async {
    await _todosCollection.doc(id).update({
      'title': newTitle,
    });
  }

  Future<void> updateTaskDescription(String id, String newDescription) async {
    await _todosCollection.doc(id).update({
      'description': newDescription,
    });
  }

  // ✅ DELETE: Menghapus Task
  Future<void> deleteTodo(String id) async {
    await _todosCollection.doc(id).delete();
  }

  // ✅ NEW: Check overdue tasks dan buat notifikasi
  Future<void> checkOverdueTasks() async {
    await _notificationService.checkAndNotifyOverdueTasks();
  }
}