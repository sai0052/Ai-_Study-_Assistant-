import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ai_student_assistant/features/tasks/domain/usecases/toggle_complete_usecase.dart';
import '../../helpers/mock_repositories.dart';

void main() {
  late MockTasksRepository mockRepository;
  late ToggleCompleteUsecase usecase;

  setUp(() {
    mockRepository = MockTasksRepository();
    usecase = ToggleCompleteUsecase(mockRepository);
  });

  test('marks a task complete successfully', () async {
    when(() => mockRepository.toggleComplete('task_1', true)).thenAnswer((_) async => const Right(null));

    final result = await usecase.call('task_1', true);

    expect(result, const Right(null));
  });
}
