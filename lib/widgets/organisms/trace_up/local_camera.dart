// screens/local_camera.dart
import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/organisms/trace_up/local_camera_widget.dart';

class LocalCamera extends StatefulWidget {
  @override
  _LocalCameraState createState() => _LocalCameraState();
}

class _LocalCameraState extends State<LocalCamera> {
  @override
  Widget build(BuildContext context) {
    return LocalCameraWidget();
  }
}
