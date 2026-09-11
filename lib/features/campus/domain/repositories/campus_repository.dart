import '../entities/announcement_entity.dart';

abstract class CampusRepository {
  Stream<List<AnnouncementEntity>> watchAnnouncements();
}
