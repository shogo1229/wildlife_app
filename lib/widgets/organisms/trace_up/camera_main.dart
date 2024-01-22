// main.dart
import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/organisms/trace_up/local_camera.dart';

class Call_LocalCamera extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LocalCamera(),
    );
  }
}
