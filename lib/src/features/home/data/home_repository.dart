import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tiktok/src/features/home/data/fake_home_repository.dart';
import 'package:tiktok/src/features/home/domain/video_model.dart';

part 'home_repository.g.dart';

abstract class HomeRepository {
  Future<List<VideoModel>> getVideos();
}

@riverpod
HomeRepository homeRepository(Ref ref) {
  return FakeHomeRepository();
}

@riverpod
FutureOr<List<VideoModel>> fetchVideos(Ref ref) {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getVideos();
}
