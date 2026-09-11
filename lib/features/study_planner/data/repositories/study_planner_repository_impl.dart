import '../../domain/entities/study_session_entity.dart';
import '../../domain/repositories/study_planner_repository.dart';
import '../datasources/study_planner_remote_datasource.dart';
import '../models/study_session_model.dart';

class StudyPlannerRepositoryImpl implements StudyPlannerRepository {
  final StudyPlannerRemoteDataSource remoteDataSource;
  StudyPlannerRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<StudySessionEntity>> watchSessions(String userId) => remoteDataSource.watchSessions(userId);

  @override
  Future<void> createSession(StudySessionEntity session) =>
      remoteDataSource.createSession(StudySessionModel(
        id: session.id,
        ownerId: session.ownerId,
        subject: session.subject,
        date: session.date,
        durationMinutes: session.durationMinutes,
        isCompleted: session.isCompleted,
      ));

  @override
  Future<void> markComplete(String sessionId, bool isCompleted) => remoteDataSource.markComplete(sessionId, isCompleted);
}
