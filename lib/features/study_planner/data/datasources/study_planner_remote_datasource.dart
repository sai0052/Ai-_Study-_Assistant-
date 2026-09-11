import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/study_session_model.dart';

abstract class StudyPlannerRemoteDataSource {
  Stream<List<StudySessionModel>> watchSessions(String userId);
  Future<void> createSession(StudySessionModel session);
  Future<void> markComplete(String sessionId, bool isCompleted);
}

class StudyPlannerRemoteDataSourceImpl implements StudyPlannerRemoteDataSource {
  final FirebaseFirestore firestore;
  StudyPlannerRemoteDataSourceImpl(this.firestore);

  CollectionReference<Map<String, dynamic>> get _sessions => firestore.collection('study_sessions');

  @override
  Stream<List<StudySessionModel>> watchSessions(String userId) {
    return _sessions
        .where('ownerId', isEqualTo: userId)
        .orderBy('date')
        .snapshots()
        .map((s) => s.docs.map(StudySessionModel.fromFirestore).toList());
  }

  @override
  Future<void> createSession(StudySessionModel session) => _sessions.doc(session.id).set(session.toMap());

  @override
  Future<void> markComplete(String sessionId, bool isCompleted) =>
      _sessions.doc(sessionId).update({'isCompleted': isCompleted});
}
