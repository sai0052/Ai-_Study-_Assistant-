import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/study_planner_remote_datasource.dart';
import '../../data/repositories/study_planner_repository_impl.dart';
import '../../domain/entities/study_session_entity.dart';
import '../../domain/repositories/study_planner_repository.dart';
import '../../domain/usecases/create_session_usecase.dart';

final studyPlannerRemoteDataSourceProvider = Provider<StudyPlannerRemoteDataSource>((ref) {
  return StudyPlannerRemoteDataSourceImpl(ref.watch(firestoreProvider));
});

final studyPlannerRepositoryProvider = Provider<StudyPlannerRepository>((ref) {
  return StudyPlannerRepositoryImpl(ref.watch(studyPlannerRemoteDataSourceProvider));
});

final createSessionUsecaseProvider = Provider((ref) => CreateSessionUsecase(ref.watch(studyPlannerRepositoryProvider)));

final studySessionsStreamProvider = StreamProvider<List<StudySessionEntity>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(studyPlannerRepositoryProvider).watchSessions(user.uid);
});

class StudyPlannerController {
  final Ref ref;
  final _uuid = const Uuid();
  StudyPlannerController(this.ref);

  Future<void> addSession({required String subject, required DateTime date, required int durationMinutes}) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;
    await ref.read(createSessionUsecaseProvider).call(
          StudySessionEntity(
            id: _uuid.v4(),
            ownerId: user.uid,
            subject: subject,
            date: date,
            durationMinutes: durationMinutes,
          ),
        );
  }
}

final studyPlannerControllerProvider = Provider((ref) => StudyPlannerController(ref));
