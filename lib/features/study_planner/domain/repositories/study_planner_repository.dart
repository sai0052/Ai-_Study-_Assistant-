import '../entities/study_session_entity.dart';

abstract class StudyPlannerRepository {
  Stream<List<StudySessionEntity>> watchSessions(String userId);
  Future<void> createSession(StudySessionEntity session);
  Future<void> markComplete(String sessionId, bool isCompleted);
}
