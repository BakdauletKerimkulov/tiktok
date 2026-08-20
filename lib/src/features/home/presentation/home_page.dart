import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok/src/core/common_widgets/alert_dialogs.dart';
import 'package:tiktok/src/core/common_widgets/async_value_widget.dart';
import 'package:tiktok/src/features/home/data/home_repository.dart';
import 'package:tiktok/src/features/home/presentation/feed_view.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosValue = ref.watch(fetchVideosProvider);

    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => showNotImplementedAlertDialog(context: context),
          icon: CircleAvatar(radius: 20),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Community', style: textTheme.titleSmall),
            Text('Following', style: textTheme.titleSmall),
            Text('For you', style: textTheme.titleSmall),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => showNotImplementedAlertDialog(context: context),
            icon: Icon(Icons.abc),
          ),
          IconButton(
            onPressed: () => showNotImplementedAlertDialog(context: context),
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: AsyncValueWidget(
        value: videosValue,
        data: (videos) => FeedView(videos: videos),
      ),
    );
  }
}
