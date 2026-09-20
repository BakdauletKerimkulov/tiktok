// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:tiktok/src/core/common_widgets/alert_dialogs.dart';
import 'package:tiktok/src/features/home/domain/video_model.dart';
import 'package:video_player/video_player.dart';

class VideoFeedItem extends StatelessWidget {
  const VideoFeedItem({
    super.key,
    required this.model,
    required this.isActive,
    required this.controller,
  });

  final VideoModel model;
  final bool isActive;
  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        VideoPlayerView(
          id: model.id,
          url: model.url,
          isActive: isActive,
          controller: controller,
        ),
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
    required this.controller,
  });
  final VideoModelId id;
  final String url;
  final bool isActive;
  final VideoPlayerController? controller;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView>
    with WidgetsBindingObserver {
  // Единственный кэш снимка value, обновляемый в _onChanged.
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isUserTapPause = false;
  bool _isWidgetVisible = false;
  bool _isAppResumed = true;
  String? _initError;
  String? _valueError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCache();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.id != oldWidget.id ||
        widget.url != oldWidget.url ||
        oldWidget.controller != widget.controller) {
      _resetCache(oldWidget.controller);
      _initCache();
    }

    if (widget.isActive != oldWidget.isActive) {
      final controller = widget.controller;
      if (controller == null) return;
      if (widget.isActive) controller.seekTo(Duration.zero);
      _applyActiveState();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isWidgetVisible = TickerMode.of(context);
    _applyActiveState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppResumed = state == AppLifecycleState.resumed;
    _applyActiveState();
  }

  void _initCache() {
    final controller = widget.controller;
    controller?.addListener(_onChanged);

    _isInitialized = controller?.value.isInitialized ?? false;
    _isPlaying = controller?.value.isPlaying ?? false;
    if (controller != null && controller.value.hasError) {
      _valueError = controller.value.errorDescription;
    }

    _applyActiveState();
  }

  void _resetCache(VideoPlayerController? controller) {
    // Сброс ВСЕГО кэша — иначе build отрисует новый контроллер
    // так, будто он уже готов.
    controller?.removeListener(_onChanged);
    _isInitialized = false;
    _isUserTapPause = false;
    _isPlaying = false;
    _initError = null;
    _valueError = null;
  }

  void _onChanged() {
    final controller = widget.controller;

    if (controller == null) return;

    final value = controller.value;

    final error = value.hasError ? value.errorDescription : null;

    if (value.isInitialized == _isInitialized &&
        value.isPlaying == _isPlaying &&
        error == _valueError) {
      return;
    }

    setState(() {
      _isInitialized = value.isInitialized;
      _isPlaying = value.isPlaying;
      _valueError = error;
    });

    _applyActiveState();
  }

  void _applyActiveState() {
    final controller = widget.controller;
    if (controller == null || !_isInitialized) return;

    if (widget.isActive &&
        !_isUserTapPause &&
        _isWidgetVisible &&
        _isAppResumed) {
      controller
        ..setPlaybackSpeed(1.0)
        ..play();
    } else {
      controller
        ..pause()
        ..setPlaybackSpeed(1.0); // иначе следующий показ стартует на 2x
    }
  }

  void _togglePlay() {
    if (!_isInitialized) return;
    _isUserTapPause = !_isUserTapPause;
    _applyActiveState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resetCache(widget.controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = _initError ?? _valueError;
    if (error != null) {
      return _ErrorView(
        message: error,
        onRetry: () => showNotImplementedAlertDialog(context: context),
      );
    }

    final controller = widget.controller;
    if (controller == null || !_isInitialized) {
      return const _LoadingView();
    }

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
