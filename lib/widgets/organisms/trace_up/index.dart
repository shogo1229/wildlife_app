import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/atoms/footerButton.dart';
import 'package:wildlife_app/widgets/organisms/trace_up/camera.dart';

class TraceUpIndex extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[traceUp(), traceUp()],
    );
  }
}
