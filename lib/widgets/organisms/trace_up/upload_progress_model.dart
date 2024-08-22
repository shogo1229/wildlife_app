// upload_progress_modal.dart
import 'package:flutter/material.dart';

class UploadProgressModal extends StatefulWidget {
  final String message;

  UploadProgressModal({required this.message});

  @override
  _UploadProgressModalState createState() => _UploadProgressModalState();
}

class _UploadProgressModalState extends State<UploadProgressModal> {
  @override
  Widget build(BuildContext context) {
    // アップロード進捗を表示する UI
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16.0),
          Text(widget.message),
        ],
      ),
    );
  }
}
