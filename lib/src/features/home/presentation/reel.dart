import 'package:flutter/material.dart';
import 'package:tiktok/src/core/common_widgets/alert_dialogs.dart';

class Reel extends StatelessWidget {
  const Reel({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(right: 0, bottom: 0, child: SideButtons()),
        Positioned(
          left: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NickName'),
                Text('Description'),
                Text('#Hashtags #Messi'),
              ],
            ),
          ),
        ),
      ],
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
