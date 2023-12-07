import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/organisms/trace_up/index.dart';

class TraceUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TraceUpPage'),
      ),
      body: TraceUpIndex(),
    );
  }
}
