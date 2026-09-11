import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/campus_remote_datasource.dart';
import '../../data/repositories/campus_repository_impl.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/repositories/campus_repository.dart';

final campusRemoteDataSourceProvider = Provider<CampusRemoteDataSource>((ref) {
  return CampusRemoteDataSourceImpl(ref.watch(firestoreProvider));
});

final campusRepositoryProvider = Provider<CampusRepository>((ref) {
  return CampusRepositoryImpl(ref.watch(campusRemoteDataSourceProvider));
});

final announcementsStreamProvider = StreamProvider<List<AnnouncementEntity>>((ref) {
  return ref.watch(campusRepositoryProvider).watchAnnouncements();
});
