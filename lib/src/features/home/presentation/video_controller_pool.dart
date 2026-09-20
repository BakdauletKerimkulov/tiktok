import 'package:tiktok/src/features/home/domain/video_model.dart';
import 'package:video_player/video_player.dart';

class VideoControllerPool {
  final Map<
    VideoModelId,
    ({VideoPlayerController controller, Future<void> ready})
  >
  _controllers = {};

  void retain(List<VideoModel> models) {
    final ids = models.map((m) => m.id).toSet();
    final poolKeysSet = _controllers.keys.toSet();
    final toDestroy = poolKeysSet.difference(ids);
    final toCreate = ids.difference(poolKeysSet);

    for (final id in toDestroy) {
      _controllers.remove(id)?.controller.dispose();
    }

    for (final id in toCreate) {
      final model = models.firstWhere((m) => m.id == id);
      final controller = VideoPlayerController.asset(model.url);
      controller.setLooping(true);
      final ready = controller.initialize();
      // ошибку разбирает страница через initializationFor
      ready.catchError((e) {});
      _controllers[id] = (controller: controller, ready: ready);
    }
  }

  Future<void>? initializationFor(VideoModelId id) {
    return _controllers[id]?.ready;
  }

  VideoPlayerController? controllerFor(VideoModelId id) {
    return _controllers[id]?.controller;
  }

  void dispose() => retain(const []);
}
