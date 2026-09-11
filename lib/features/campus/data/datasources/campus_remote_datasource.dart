import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement_model.dart';

/// Reads from a shared `announcements` collection — in a real deployment
/// this would be scoped `colleges/{collegeId}/announcements` and written by
/// a college admin dashboard or Cloud Function, not by student clients.
abstract class CampusRemoteDataSource {
  Stream<List<AnnouncementModel>> watchAnnouncements();
}

class CampusRemoteDataSourceImpl implements CampusRemoteDataSource {
  final FirebaseFirestore firestore;
  CampusRemoteDataSourceImpl(this.firestore);

  @override
  Stream<List<AnnouncementModel>> watchAnnouncements() {
    return firestore
        .collection('announcements')
        .orderBy('postedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map(AnnouncementModel.fromFirestore).toList());
  }
}
