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

  // 1. CREATE: Tambah Task Baru
  Future<void> addTodo(String title, String category, DateTime deadline, String description) async {
    await _todosCollection.add({
      'title': title,
      'description': description,
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
    await _todosCollection.doc(id).update({
      'isCompleted': !currentStatus,
    });
  }

  Future<void> updateTaskTitle(String id, String newTitle) async {
    await _todosCollection.doc(id).update({
      'title': newTitle,
    });
  }

  Future<void> updateTaskDescription(String id, String newDescription) async {
    await _todosCollection.doc(id).update({
      'description': newDescription, // Pastikan field 'description' ada di model/firebase
    });
  }

  // 4. DELETE: Menghapus Task
  Future<void> deleteTodo(String id) async {
    await _todosCollection.doc(id).delete();
  }
}