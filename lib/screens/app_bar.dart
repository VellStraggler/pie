// app_bar_widget.dart
import 'package:flutter/material.dart';
import '../display/clock.dart';

/// Builds the app bar at the top of screen.
class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const MyAppBar({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(30.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Clock(),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}
