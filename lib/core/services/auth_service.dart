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
  static String? getCurrentUserEmail() => _auth.currentUser?.email;

  static String? getAuthProvider() {
    final user = _auth.currentUser;
    if (user == null || user.providerData.isEmpty) return null;
    return user.providerData.first.providerId;
  }

  // create or update (firestore)
  static Future<void> _createOrUpdateUserInFirestore(
      User user, {
        String? displayName,
        String? bio,
        String? photoURL,
      }) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);

      final data = <String, dynamic>{
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': displayName ?? user.displayName ?? '',
        'emailVerified': user.emailVerified,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // add photoURL only if provided (can be null, Base64, or regular URL)
      if (photoURL != null) {
        data['photoURL'] = photoURL;
      } else {
        // Keep existing photoURL if not updating
        final existingDoc = await userRef.get();
        if (existingDoc.exists) {
          final existingData = existingDoc.data();
          if (existingData != null && existingData.containsKey('photoURL')) {
            data['photoURL'] = existingData['photoURL'];
          } else {
            data['photoURL'] = user.photoURL ?? '';
          }
        } else {
          data['photoURL'] = user.photoURL ?? '';
        }
      }

      if (bio != null) {
        data['bio'] = bio;
      }

      final doc = await userRef.get();

      if (!doc.exists) {
        // for new user, set default bio and notification setting
        data['createdAt'] = FieldValue.serverTimestamp();
        data['provider'] = user.providerData.isNotEmpty
            ? user.providerData.first.providerId
            : 'password';
        if (!data.containsKey('bio')) {
          data['bio'] = 'Update bio in here';
        }
        data['notificationsEnabled'] = true;

        await userRef.set(data);
      } else {
        // For existing user, only update provided fields
        await userRef.update(data);
      }
    } catch (e) {
      print('Error in _createOrUpdateUserInFirestore: $e');
      rethrow;
    }
  }

  // for google sign in
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

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

  //  input field with email dan password sign in manually
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
          bio: 'Update bio in here',
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

  //  re-authen for user
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
      try {
        await _firestore.collection('users').doc(uid).delete();
      } catch (_) {}

      try {
        if (await _googleSignIn.isSignedIn()) {
          await _googleSignIn.signOut();
        }
      } catch (_) {}

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

  //  update profile with support base64 and remove photo
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
    String? bio,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      print('=== Starting profile update ===');
      print('DisplayName: $displayName');
      print('Bio: $bio');
      print('PhotoURL: ${photoURL == null ? "null (no change)" : photoURL.isEmpty ? "empty string (REMOVED)" : photoURL.startsWith("data:image") ? "Base64 (length ${photoURL.length})" : "URL: $photoURL"}');

      // Update Firebase Auth profile (ONLY if not Base64)
      if (displayName != null) {
        await user.updateDisplayName(displayName);
        print('Display name updated in Firebase Auth');
      }

      // handle photo in Firebase Auth
      if (photoURL != null) {
        if (photoURL.isEmpty) {
          // photo was removed, set to null in Firebase Auth
          await user.updatePhotoURL(null);
          print('Photo REMOVED from Firebase Auth (set to null)');
        } else if (!photoURL.startsWith('data:image')) {
          // regular URL - update Firebase Auth
          await user.updatePhotoURL(photoURL);
          print('Photo URL updated in Firebase Auth');
        } else {
          // base64 - skip Firebase Auth (doesn't support Base64)
          print('⏭ Skipping Firebase Auth for Base64 image');
        }
      }

      await user.reload();
      print(' Firebase Auth user reloaded');

      // update Firestore (supports everything including empty string)
      final userRef = _firestore.collection('users').doc(user.uid);

      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) {
        updateData['displayName'] = displayName;
      }

      if (bio != null) {
        updateData['bio'] = bio;
      }

      // always update photoURL in Firestore when provided
      // empty string = photo removed, Base64 = new photo, URL = photo URL
      if (photoURL != null) {
        updateData['photoURL'] = photoURL;
        print('Storing photoURL in Firestore: ${photoURL.isEmpty ? "EMPTY (removed)" : photoURL.startsWith("data:image") ? "Base64" : "URL"}');
      }

      await userRef.update(updateData);
      print('Firestore updated successfully');
      print('=== Profile update completed ===');

    } catch (e) {
      print('Error in updateUserProfile: $e');
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  static Future<void> updateUserBio(String bio) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      await _firestore.collection('users').doc(user.uid).update({
        'bio': bio,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      throw Exception('Failed to update bio');
    }
  }

  // update only photo URL in Firestore - SUPPORT BASE64
  static Future<void> updateUserPhotoURL(String photoURL) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      // only update Firebase Auth if it's not base64
      if (!photoURL.startsWith('data:image')) {
        await user.updatePhotoURL(photoURL);
        await user.reload();
      }

      // always update Firestore (supports Base64)
      await _firestore.collection('users').doc(user.uid).update({
        'photoURL': photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update photo: ${e.toString()}');
    }
  }

  // update user data (general purpose for settings like notifications)
  static Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user signed in');

      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(user.uid).set(
        data,
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to update user data: ${e.toString()}');
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