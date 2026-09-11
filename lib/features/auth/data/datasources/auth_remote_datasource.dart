import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn({required String email, required String password});
  Future<UserModel> signUp({required String email, required String password, required String name});
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Stream<UserModel?> get authStateChanges;
  Future<void> updateProfile({required String uid, String? name, String? collegeName, String? course});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final fb.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
  });

  CollectionReference<Map<String, dynamic>> get _usersCollection => firestore.collection('users');

  @override
  Future<UserModel> signIn({required String email, required String password}) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return _fetchUserProfile(credential.user!.uid);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign in failed');
    }
  }

  @override
  Future<UserModel> signUp({required String email, required String password, required String name}) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      final user = credential.user!;
      await user.updateDisplayName(name);

      final model = UserModel(uid: user.uid, email: email, name: name);
      await _usersCollection.doc(user.uid).set(model.toMap());
      return model;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign up failed');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw AuthException('Google sign-in was cancelled');

      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user!;

      final docSnapshot = await _usersCollection.doc(user.uid).get();
      if (!docSnapshot.exists) {
        final model = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? 'Student',
          photoUrl: user.photoURL,
        );
        await _usersCollection.doc(user.uid).set(model.toMap());
        return model;
      }
      return UserModel.fromMap(docSnapshot.data()!);
    } catch (e) {
      throw AuthException('Google sign-in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([firebaseAuth.signOut(), googleSignIn.signOut()]);
  }

  @override
  Stream<UserModel?> get authStateChanges {
    // Uses asyncExpand (not asyncMap) so we can switch to a LIVE Firestore
    // snapshot stream for the current user's profile doc. This means any
    // update to that document — like from EditProfileScreen — pushes a
    // fresh UserModel through automatically, without needing a full app
    // restart or a sign-out/sign-in cycle to see the change reflected.
    return firebaseAuth.authStateChanges().asyncExpand((fbUser) {
      if (fbUser == null) return Stream.value(null);
      return _usersCollection.doc(fbUser.uid).snapshots().map((doc) {
        if (!doc.exists) return null;
        return UserModel.fromMap(doc.data()!);
      });
    });
  }

  @override
  Future<void> updateProfile({required String uid, String? name, String? collegeName, String? course}) async {
    await _usersCollection.doc(uid).update({
      if (name != null) 'name': name,
      if (collegeName != null) 'collegeName': collegeName,
      if (course != null) 'course': course,
    });
    if (name != null) {
      await firebaseAuth.currentUser?.updateDisplayName(name);
    }
  }

  Future<UserModel> _fetchUserProfile(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) throw AuthException('User profile not found');
    return UserModel.fromMap(doc.data()!);
  }
}