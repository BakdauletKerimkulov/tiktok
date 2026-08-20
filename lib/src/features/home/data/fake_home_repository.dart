import 'package:tiktok/src/features/home/data/home_repository.dart';
import 'package:tiktok/src/features/home/domain/video_model.dart';

const _videos = [
  VideoModel(id: '1', url: 'assets/videos/video1.mp4'),
  VideoModel(id: '2', url: 'assets/videos/video2.mp4'),
];

class FakeHomeRepository extends HomeRepository {
  @override
  Future<List<VideoModel>> getVideos() async {
    return Future.value(_videos);
  }
}
