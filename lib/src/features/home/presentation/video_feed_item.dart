// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:tiktok/src/core/common_widgets/alert_dialogs.dart';
import 'package:tiktok/src/features/home/domain/video_model.dart';
import 'package:video_player/video_player.dart';

class VideoFeedItem extends StatelessWidget {
  const VideoFeedItem({super.key, required this.model, required this.isActive});

  final VideoModel model;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        VideoPlayerView(id: model.id, url: model.url, isActive: isActive),
        Positioned(right: 0, bottom: 0, child: SideButtons()),
        Positioned(
          left: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('NickName'),
                const Text('Description'),
                const Text('#Hashtags #Messi'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({
    super.key,
    required this.id,
    required this.url,
    required this.isActive,
  });
  final VideoModelId id;
  final String url;
  final bool isActive;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;

  // Единственный кэш снимка value, обновляемый в _onChanged.
  bool _isInitialized = false;
  bool _isPlaying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initController();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.id != oldWidget.id || widget.url != oldWidget.url) {
      _disposeController();
      _initController(); // isActive применится в .then()
      return; // ВАЖНО: не трогаем свежий контроллер ниже
    }

    if (widget.isActive != oldWidget.isActive) {
      _applyActiveState();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !_isInitialized) return;

    switch (state) {
      case AppLifecycleState.resumed:
        if (widget.isActive) controller.play();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        controller.pause();
    }
  }

  void _initController() {
    final controller = VideoPlayerController.asset(widget.url);
    _controller = controller;

    controller
      ..setLooping(true)
      ..addListener(_onChanged);

    controller
        .initialize()
        .then((_) {
          if (!mounted || !identical(controller, _controller)) return;
          if (widget.isActive) controller.play();
        })
        .catchError((Object e) {
          if (!mounted || !identical(controller, _controller)) return;
          setState(() => _error = e.toString());
        });
  }

  void _disposeController() {
    _controller
      ?..removeListener(_onChanged)
      ..dispose();
    _controller = null;

    // Сброс ВСЕГО кэша — иначе build отрисует новый контроллер
    // так, будто он уже готов.
    _isInitialized = false;
    _isPlaying = false;
    _error = null;
  }

  void _onChanged() {
    final value = _controller?.value;
    if (value == null) return;

    final error = value.hasError ? value.errorDescription : null;

    if (value.isInitialized == _isInitialized &&
        value.isPlaying == _isPlaying &&
        error == _error) {
      return;
    }

    setState(() {
      _isInitialized = value.isInitialized;
      _isPlaying = value.isPlaying;
      _error ??= error; // ошибка из catchError имеет приоритет
    });
  }

  void _applyActiveState() {
    final controller = _controller;
    if (controller == null || !_isInitialized) return;

    if (widget.isActive) {
      controller
        ..setPlaybackSpeed(1.0)
        ..seekTo(Duration.zero)
        ..play();
    } else {
      controller
        ..pause()
        ..setPlaybackSpeed(1.0); // иначе следующий показ стартует на 2x
    }
  }

  void _togglePlay() {
    final controller = _controller;
    if (controller == null || !_isInitialized) return;
    _isPlaying ? controller.pause() : controller.play();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error != null) {
      return _ErrorView(
        message: error,
        onRetry: () => showNotImplementedAlertDialog(context: context),
      );
    }

    final controller = _controller;
    if (controller == null || !_isInitialized) return const _LoadingView();

    final size = controller.value.size;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.isActive ? _togglePlay : null,
      onLongPressStart: widget.isActive
          ? (_) => controller.setPlaybackSpeed(2.0)
          : null,
      onLongPressEnd: widget.isActive
          ? (_) => controller.setPlaybackSpeed(1.0)
          : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              // Защита от Size.zero на некоторых кодеках/платформах.
              width: size.width <= 0 ? 1 : size.width,
              height: size.height <= 0 ? 1 : size.height,
              child: VideoPlayer(controller),
            ),
          ),
          if (widget.isActive && !_isPlaying)
            const Center(
              child: Icon(Icons.play_arrow, size: 80, color: Colors.white70),
            ),
        ],
      ),
    );
  }
}

class SideButtons extends StatelessWidget {
  const SideButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => showNotImplementedAlertDialog(context: context),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/person_placeholder.png'),
            ),
          ),
          IconButton(
            onPressed: () => showNotImplementedAlertDialog(context: context),
            icon: Icon(Icons.favorite),
          ),
          IconButton(
            onPressed: () => showNotImplementedAlertDialog(context: context),
            icon: Icon(Icons.comment),
          ),
          IconButton(
            onPressed: () => showNotImplementedAlertDialog(context: context),
            icon: Icon(Icons.archive),
          ),
          IconButton(
            onPressed: () => showNotImplementedAlertDialog(context: context),
            icon: Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black,
      child: SizedBox.expand(
        child: Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: Colors.black,
      child: SizedBox.expand(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white70,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Не удалось загрузить видео',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Повторить'),
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
