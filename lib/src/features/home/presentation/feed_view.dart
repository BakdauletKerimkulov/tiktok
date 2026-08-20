// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:tiktok/src/features/home/domain/video_model.dart';
import 'package:tiktok/src/features/home/presentation/video_feed_item.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key, required this.videos});

  final List<VideoModel> videos;

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final _controller = PageController();

  int _activeIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        if (notification.depth != 0) return false;
        final page = _controller.page?.round() ?? 0;
        if (page != _activeIndex) setState(() => _activeIndex = page);
        return false;
      },
      child: PageView.builder(
        controller: _controller,
        scrollDirection: Axis.vertical,
        itemCount: widget.videos.length,
        itemBuilder: (context, index) {
          final video = widget.videos[index];
          return VideoFeedItem(model: video, isActive: index == _activeIndex);
        },
      ),
    );
  }
}
