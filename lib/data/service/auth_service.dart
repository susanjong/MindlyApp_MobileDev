import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Stream untuk mendengarkan perubahan auth state
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ==================== CORE FUNCTION ====================
  // FUNGSI INI YANG MEMBUAT TABEL USERS DI FIRESTORE
  static Future<void> _createOrUpdateUserInFirestore(User user, {String? displayName}) async {
    try {
      print('🔄 Starting to create/update user in Firestore...');
      print('👤 User ID: ${user.uid}');
      print('📧 Email: ${user.email}');

      final userDoc = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      final userData = {
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': displayName ?? user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
        'emailVerified': user.emailVerified,
      };

      if (!docSnapshot.exists) {
        // User baru - buat dokumen baru
        userData['createdAt'] = FieldValue.serverTimestamp();
        userData['provider'] = user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : 'password';

        await userDoc.set(userData);
        print('✅ NEW USER CREATED in Firestore successfully!');
      } else {
        // User sudah ada - update data
        await userDoc.update(userData);
        print('✅ USER UPDATED in Firestore successfully!');
      }

      print('🎉 Firestore operation completed!');
    } catch (e) {
      print('❌ ERROR creating/updating user in Firestore: $e');
      print('📝 Stack trace: ${StackTrace.current}');
      // JANGAN throw error, biarkan proses login tetap lanjut
      // User tetap bisa login meskipun gagal save ke Firestore
    }
  }

  // ==================== GOOGLE SIGN IN ====================
  static Future<UserCredential?> signInWithGoogle() async {
    UserCredential? userCredential;

    try {
      print('🚀 Starting Google Sign-In process...');

      // PENTING: Sign out dulu untuk clear cache
      await _googleSignIn.signOut();
      print('🔓 Previous session cleared');

      // Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('❌ User cancelled Google Sign-In');
        return null;
      }

      print('✅ Google account selected: ${googleUser.email}');

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('🔑 Access Token: ${googleAuth.accessToken != null ? "AVAILABLE" : "NULL"}');
      print('🔑 ID Token: ${googleAuth.idToken != null ? "AVAILABLE" : "NULL"}');

      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        throw Exception('Failed to get authentication tokens from Google');
      }

      // PENTING: Gunakan idToken untuk accessToken dan sebaliknya
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔐 Firebase credential created');

      // Sign in to Firebase
      userCredential = await _auth.signInWithCredential(credential);

      print('🎉 Firebase authentication successful!');
      print('👤 User: ${userCredential.user?.email}');

      // OTOMATIS BUAT/UPDATE USER DI FIRESTORE - INI YANG BIKIN TABEL
      if (userCredential.user != null) {
        print('💾 Saving user to Firestore...');
        await _createOrUpdateUserInFirestore(userCredential.user!);
      }

      return userCredential;

    } on FirebaseAuthException catch (e) {
      print('🔥 FirebaseAuthException: ${e.code}');
      print('📝 Message: ${e.message}');

      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception('Account already exists with different login method');
        case 'invalid-credential':
          throw Exception('Invalid credentials. Please try again');
        case 'operation-not-allowed':
          throw Exception('Google Sign-In is not enabled. Contact support');
        case 'user-disabled':
          throw Exception('This account has been disabled');
        case 'user-not-found':
          throw Exception('No account found');
        case 'wrong-password':
          throw Exception('Wrong password');
        default:
          throw Exception('Sign-in failed: ${e.message}');
      }
    } catch (e) {
      print('💥 Unexpected error: $e');
      print('📝 Stack: ${StackTrace.current}');

      if (e.toString().contains('network')) {
        throw Exception('No internet connection');
      }
      throw Exception('Google Sign-In failed. Please try again');
    }
  }

  // ==================== EMAIL/PASSWORD SIGN IN ====================
  static Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      print('🚀 Starting email sign-in...');
      print('📧 Email: $email');

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      print('✅ Email sign-in successful!');

      // OTOMATIS UPDATE USER DI FIRESTORE
      if (userCredential.user != null) {
        print('💾 Updating user in Firestore...');
        await _createOrUpdateUserInFirestore(userCredential.user!);
      }

      return userCredential;

    } on FirebaseAuthException catch (e) {
      print('🔥 FirebaseAuthException: ${e.code}');

      switch (e.code) {
        case 'user-not-found':
          throw Exception('No account found with this email');
        case 'wrong-password':
          throw Exception('Incorrect password');
        case 'invalid-email':
          throw Exception('Invalid email format');
        case 'user-disabled':
          throw Exception('This account has been disabled');
        case 'too-many-requests':
          throw Exception('Too many attempts. Try again later');
        case 'invalid-credential':
          throw Exception('Invalid email or password');
        default:
          throw Exception('Sign-in failed: ${e.message}');
      }
    } catch (e) {
      print('💥 Error: $e');
      throw Exception('Sign-in failed. Please try again');
    }
  }

  // ==================== CREATE ACCOUNT ====================
  static Future<UserCredential?> createAccountWithEmailPassword(
      String email,
      String password,
      {String? displayName}
      ) async {
    try {
      print('🚀 Starting account creation...');
      print('📧 Email: $email');
      print('👤 Name: ${displayName ?? "Not provided"}');

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      print('✅ Account created in Firebase Auth!');

      // Update display name jika ada
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName);
        await userCredential.user?.reload();
        print('✅ Display name updated: $displayName');
      }

      // Send verification email
      try {
        await userCredential.user?.sendEmailVerification();
        print('📧 Verification email sent');
      } catch (e) {
        print('⚠️ Could not send verification email: $e');
      }

      // OTOMATIS BUAT USER DI FIRESTORE - INI YANG BIKIN TABEL
      if (userCredential.user != null) {
        print('💾 Creating user in Firestore...');
        await _createOrUpdateUserInFirestore(
            userCredential.user!,
            displayName: displayName
        );
      }

      print('🎉 Account creation complete!');
      return userCredential;

    } on FirebaseAuthException catch (e) {
      print('🔥 FirebaseAuthException: ${e.code}');

      switch (e.code) {
        case 'weak-password':
          throw Exception('Password is too weak. Use 6+ characters');
        case 'email-already-in-use':
          throw Exception('Email already registered. Try signing in');
        case 'invalid-email':
          throw Exception('Invalid email format');
        case 'operation-not-allowed':
          throw Exception('Email/password accounts not enabled');
        default:
          throw Exception('Account creation failed: ${e.message}');
      }
    } catch (e) {
      print('💥 Error: $e');
      throw Exception('Account creation failed. Please try again');
    }
  }

  // ==================== DELETE ACCOUNT ====================
  /// Menghapus akun user secara permanen dari Firebase Auth dan Firestore
  /// PERINGATAN: Aksi ini tidak dapat dibatalkan!
  static Future<void> deleteAccount() async {
    try {
      print('🚀 Starting account deletion process...');

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final userId = user.uid;
      final userEmail = user.email;
      print('👤 Deleting account for: $userEmail (ID: $userId)');

      // STEP 1: Hapus data user dari Firestore
      print('🗑️ Step 1: Deleting user data from Firestore...');
      try {
        await _firestore.collection('users').doc(userId).delete();
        print('✅ User data deleted from Firestore');
      } catch (e) {
        print('⚠️ Warning: Could not delete Firestore data: $e');
        // Lanjutkan proses meskipun gagal hapus Firestore
      }

      // STEP 2: Sign out dari Google jika login via Google
      print('🔓 Step 2: Signing out from Google (if applicable)...');
      try {
        if (await _googleSignIn.isSignedIn()) {
          await _googleSignIn.signOut();
          print('✅ Signed out from Google');
        }
      } catch (e) {
        print('⚠️ Warning: Could not sign out from Google: $e');
      }

      // STEP 3: Hapus akun dari Firebase Authentication
      print('🔥 Step 3: Deleting account from Firebase Authentication...');
      await user.delete();
      print('✅ Account deleted from Firebase Auth');

      print('🎉 ACCOUNT DELETION COMPLETE!');
      print('📧 Deleted email: $userEmail');

    } on FirebaseAuthException catch (e) {
      print('🔥 FirebaseAuthException: ${e.code}');
      print('📝 Message: ${e.message}');

      switch (e.code) {
        case 'requires-recent-login':
        // User harus login ulang sebelum hapus akun
          throw Exception(
              'For security reasons, please log in again before deleting your account'
          );
        case 'no-current-user':
          throw Exception('No user is currently signed in');
        default:
          throw Exception('Failed to delete account: ${e.message}');
      }
    } catch (e) {
      print('💥 Unexpected error during account deletion: $e');
      print('📝 Stack trace: ${StackTrace.current}');

      if (e.toString().contains('network')) {
        throw Exception('No internet connection. Please check your network');
      }
      throw Exception('Failed to delete account. Please try again');
    }
  }

  /// Re-authenticate user sebelum hapus akun (untuk keamanan)
  /// Dipanggil jika user mendapat error 'requires-recent-login'
  static Future<void> reauthenticateUser(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user signed in');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      print('✅ User re-authenticated successfully');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw Exception('Incorrect password');
        case 'user-mismatch':
          throw Exception('Credential does not match current user');
        case 'invalid-credential':
          throw Exception('Invalid password');
        default:
          throw Exception('Re-authentication failed: ${e.message}');
      }
    }
  }

  /// Re-authenticate untuk Google Sign-In users
  static Future<void> reauthenticateWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.currentUser?.reauthenticateWithCredential(credential);
      print('✅ User re-authenticated with Google successfully');
    } catch (e) {
      throw Exception('Google re-authentication failed');
    }
  }

  // ==================== UPDATE PROFILE ====================
  static Future<void> updateUserProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      await user.reload();

      // Update di Firestore juga
      await _createOrUpdateUserInFirestore(user, displayName: displayName);

      print('✅ Profile updated successfully');
    } catch (e) {
      print('❌ Error updating profile: $e');
      throw Exception('Failed to update profile');
    }
  }

  // ==================== GET USER DATA ====================
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();

      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Stream user data from Firestore
  static Stream<DocumentSnapshot<Map<String, dynamic>>>? getUserDataStream() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  // ==================== OTHER FUNCTIONS ====================
  static Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      print('Error sending email verification: $e');
      throw Exception('Failed to send verification email');
    }
  }

  static bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  static Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      print('Error reloading user: $e');
    }
  }

  static Future<void> signOut() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Error signing out: $e');
      throw Exception('Sign-out failed');
    }
  }

  static bool isSignedIn() {
    return _auth.currentUser != null;
  }

  static String? getUserDisplayName() {
    return _auth.currentUser?.displayName;
  }

  static String? getUserEmail() {
    return _auth.currentUser?.email;
  }

  static String? getUserPhotoURL() {
    return _auth.currentUser?.photoURL;
  }

  /// Mendapatkan provider yang digunakan user untuk login
  static String? getAuthProvider() {
    final user = _auth.currentUser;
    if (user == null || user.providerData.isEmpty) return null;
    return user.providerData.first.providerId;
  }
}