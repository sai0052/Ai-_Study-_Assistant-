import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ai_student_assistant/core/error/failures.dart';
import 'package:ai_student_assistant/features/auth/domain/entities/user_entity.dart';
import 'package:ai_student_assistant/features/auth/domain/usecases/sign_in_usecase.dart';
import '../../helpers/mock_repositories.dart';

void main() {
  late MockAuthRepository mockRepository;
  late SignInUsecase usecase;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = SignInUsecase(mockRepository);
  });

  const testEmail = 'student@college.edu';
  const testPassword = 'password123';
  const testUser = UserEntity(uid: 'uid_123', email: testEmail, name: 'Test Student');

  test('returns UserEntity when sign in succeeds', () async {
    // Arrange
    when(() => mockRepository.signIn(email: testEmail, password: testPassword))
        .thenAnswer((_) async => const Right(testUser));

    // Act
    final result = await usecase.call(email: testEmail, password: testPassword);

    // Assert
    expect(result, const Right(testUser));
  });

  test('returns AuthFailure when sign in fails', () async {
    // Arrange
    when(() => mockRepository.signIn(email: testEmail, password: testPassword))
        .thenAnswer((_) async => const Left(AuthFailure('Invalid credentials')));

    // Act
    final result = await usecase.call(email: testEmail, password: testPassword);

    // Assert
    expect(result, const Left(AuthFailure('Invalid credentials')));
  });
}
