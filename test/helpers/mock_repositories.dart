import 'package:mocktail/mocktail.dart';
import 'package:ai_student_assistant/features/auth/domain/repositories/auth_repository.dart';
import 'package:ai_student_assistant/features/tasks/domain/repositories/tasks_repository.dart';
import 'package:ai_student_assistant/features/ai_assistant/domain/repositories/ai_repository.dart';

/// Shared mock classes for unit tests across features.
class MockAuthRepository extends Mock implements AuthRepository {}
class MockTasksRepository extends Mock implements TasksRepository {}
class MockAiRepository extends Mock implements AiRepository {}
