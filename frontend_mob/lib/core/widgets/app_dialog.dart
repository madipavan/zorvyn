import 'package:flutter/material.dart';

class AppDialog {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'OK',
  }) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}
