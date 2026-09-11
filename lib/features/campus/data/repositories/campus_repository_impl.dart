import '../../domain/entities/announcement_entity.dart';
import '../../domain/repositories/campus_repository.dart';
import '../datasources/campus_remote_datasource.dart';

class CampusRepositoryImpl implements CampusRepository {
  final CampusRemoteDataSource remoteDataSource;
  CampusRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<AnnouncementEntity>> watchAnnouncements() => remoteDataSource.watchAnnouncements();
}
