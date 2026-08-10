import 'package:flutter/material.dart';
import 'package:tiktok/src/core/common_widgets/alert_dialogs.dart';
import 'package:tiktok/src/features/home/presentation/reel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
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
      body: Reel(),
    );
  }
}
