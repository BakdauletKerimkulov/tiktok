// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tiktok/src/features/home/domain/video_model.dart';
import 'package:tiktok/src/features/home/presentation/video_controller_pool.dart';
import 'package:tiktok/src/features/home/presentation/video_feed_item.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key, required this.videos})
    : assert(videos.length > 0, "Videos mustn't be empty");

  final List<VideoModel> videos;

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final _controller = PageController();
  final VideoControllerPool _pool = VideoControllerPool();

  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _syncPool();
  }

  void _syncPool() {
    final videos = widget.videos;
    final start = max(0, _activeIndex - 1);
    final end = min(videos.length, _activeIndex + 2);
    final preparingVideos = videos.sublist(start, end);
    _pool.retain(preparingVideos);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pool.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FeedView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final currActiveIndex = _activeIndex.clamp(0, widget.videos.length - 1);
    if (currActiveIndex != _activeIndex) {
      _activeIndex = currActiveIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _controller.hasClients) {
          _controller.jumpToPage(_activeIndex);
        }
      });
    }

    if (!listEquals(widget.videos, oldWidget.videos)) {
      _syncPool();
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        if (notification.depth != 0) return false;
        final page = _controller.page?.round() ?? 0;
        if (page != _activeIndex) {
          setState(() {
            _activeIndex = page;
          });
          _syncPool();
        }
        return false;
      },
      child: PageView.builder(
        controller: _controller,
        scrollDirection: Axis.vertical,
        itemCount: widget.videos.length,
        itemBuilder: (context, index) {
          final video = widget.videos[index];
          return VideoFeedItem(
            model: video,
            isActive: index == _activeIndex,
            controller: _pool.controllerFor(video.id),
          );
        },
      ),
    );
  }
}
