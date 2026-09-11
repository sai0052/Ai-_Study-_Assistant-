import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failures.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/google_sign_in_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';

// ---- Dependency wiring (this is our lightweight DI, no extra package needed) ----

final firebaseAuthProvider = Provider<fb.FirebaseAuth>((ref) => fb.FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final googleSignInProvider = Provider<GoogleSignIn>((ref) => GoogleSignIn());

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

final signInUsecaseProvider = Provider((ref) => SignInUsecase(ref.watch(authRepositoryProvider)));
final signUpUsecaseProvider = Provider((ref) => SignUpUsecase(ref.watch(authRepositoryProvider)));
final googleSignInUsecaseProvider = Provider((ref) => GoogleSignInUsecase(ref.watch(authRepositoryProvider)));
final signOutUsecaseProvider = Provider((ref) => SignOutUsecase(ref.watch(authRepositoryProvider)));

// ---- Auth state stream (drives routing: logged in vs logged out) ----

final authStateChangesProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// ---- Controller for login/register screens (loading + error state) ----

class AuthController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  AuthController(this.ref) : super(const AsyncValue.data(null));

  Future<Failure?> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await ref.read(signInUsecaseProvider).call(email: email, password: password);
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return failure;
      },
      (_) {
        state = const AsyncValue.data(null);
        return null;
      },
    );
  }

  Future<Failure?> signUp(String email, String password, String name) async {
    state = const AsyncValue.loading();
    final result = await ref.read(signUpUsecaseProvider).call(email: email, password: password, name: name);
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return failure;
      },
      (_) {
        state = const AsyncValue.data(null);
        return null;
      },
    );
  }

  Future<Failure?> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final result = await ref.read(googleSignInUsecaseProvider).call();
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return failure;
      },
      (_) {
        state = const AsyncValue.data(null);
        return null;
      },
    );
  }

  Future<void> signOut() async {
    await ref.read(signOutUsecaseProvider).call();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref);
});
