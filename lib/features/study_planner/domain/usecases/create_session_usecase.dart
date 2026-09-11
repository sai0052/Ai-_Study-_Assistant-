import '../entities/study_session_entity.dart';
import '../repositories/study_planner_repository.dart';

class CreateSessionUsecase {
  final StudyPlannerRepository repository;
  CreateSessionUsecase(this.repository);
  Future<void> call(StudySessionEntity session) => repository.createSession(session);
}
