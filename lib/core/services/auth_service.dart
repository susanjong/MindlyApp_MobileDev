import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // getters
  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static bool isSignedIn() => _auth.currentUser != null;
  static bool isEmailVerified() => _auth.currentUser?.emailVerified ?? false;
  static String? getUserDisplayName() => _auth.currentUser?.displayName;
  static String? getUserEmail() => _auth.currentUser?.email;
  static String? getUserPhotoURL() => _auth.currentUser?.photoURL;

  static String? getAuthProvider() {
    final user = _auth.currentUser;
    if (user == null || user.providerData.isEmpty) return null;
    return user.providerData.first.providerId;
  }

  //  FIRESTORE: Create / Update Use
  static Future<void> _createOrUpdateUserInFirestore(
      User user, {
        String? displayName,
      }) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);

      final data = {
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': displayName ?? user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'emailVerified': user.emailVerified,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final doc = await userRef.get();

      if (!doc.exists) {
        data['createdAt'] = FieldValue.serverTimestamp();
        data['provider'] = user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : 'password';

        await userRef.set(data);
      } else {
        await userRef.update(data);
      }
    } catch (_) {
    }
  }

  // for google sign in
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut(); // Clear cache

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _createOrUpdateUserInFirestore(userCredential.user!);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception('Account already exists with different login method');
        case 'invalid-credential':
          throw Exception('Invalid credentials. Please try again');
        case 'operation-not-allowed':
          throw Exception('Google Sign-In is not enabled');
        case 'user-disabled':
          throw Exception('This account has been disabled');
        default:
          throw Exception(e.message ?? 'Google Sign-In failed');
      }
    } catch (_) {
      throw Exception('Google Sign-In failed. Please try again');
    }
  }

  //  email dan password sign in
  static Future<UserCredential?> signInWithEmailPassword(
      String email,
      String password,
      ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        await _createOrUpdateUserInFirestore(credential.user!);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No account found with this email');
        case 'wrong-password':
          throw Exception('Incorrect password');
        case 'invalid-email':
          throw Exception('Invalid email format');
        case 'user-disabled':
          throw Exception('This account has been disabled');
        case 'invalid-credential':
          throw Exception('Invalid email or password');
        default:
          throw Exception(e.message ?? 'Sign-in failed');
      }
    }
  }

  //  create account
  static Future<UserCredential?> createAccountWithEmailPassword(
      String email,
      String password, {
        String? displayName,
      }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
        await credential.user?.reload();
      }

      // send verification email
      try {
        await credential.user?.sendEmailVerification();
      } catch (_) {}

      if (credential.user != null) {
        await _createOrUpdateUserInFirestore(
          credential.user!,
          displayName: displayName,
        );
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw Exception('Password is too weak. Use 6+ characters');
        case 'email-already-in-use':
          throw Exception('Email already registered. Try signing in');
        case 'invalid-email':
          throw Exception('Invalid email format');
        default:
          throw Exception(e.message ?? 'Failed to create account');
      }
    }
  }

  //  reset password using email and password reset link
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw Exception('Invalid email format');
        case 'user-not-found':
          throw Exception('Email not registered. Please sign up first.');
        default:
          throw Exception(e.message ?? 'Failed to send reset password email');
      }
    }
  }

  //  RE-AUTHENTICATE USER
  static Future<void> reauthenticateUser(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No user signed in');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw Exception('Incorrect password');
        case 'user-mismatch':
          throw Exception('Credential does not match current user');
        case 'invalid-credential':
          throw Exception('Invalid password');
        default:
          throw Exception(e.message ?? 'Re-authentication failed');
      }
    }
  }

  static Future<void> reauthenticateWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.currentUser?.reauthenticateWithCredential(credential);
    } catch (_) {
      throw Exception('Google re-authentication failed');
    }
  }

  //  delete account
  static Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      final uid = user.uid;

      // Delete Firestore data
      try {
        await _firestore.collection('users').doc(uid).delete();
      } catch (_) {}

      try {
        if (await _googleSignIn.isSignedIn()) {
          await _googleSignIn.signOut();
        }
      } catch (_) {}

      // delete firebase auth account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'requires-recent-login':
          throw Exception(
            'For security reasons, please log in again before deleting your account',
          );
        default:
          throw Exception(e.message ?? 'Failed to delete account');
      }
    }
  }

  //  update profile
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      await user.reload();

      // update in Firestore
      await _createOrUpdateUserInFirestore(user, displayName: displayName);
    } catch (_) {
      throw Exception('Failed to update profile');
    }
  }

  //  get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();

      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>>? getUserDataStream() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  // other function
  static Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (_) {
      throw Exception('Failed to send verification email');
    }
  }

  static Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (_) {}
  }

  static Future<void> signOut() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (_) {
      throw Exception('Sign-out failed');
    }
  }
}