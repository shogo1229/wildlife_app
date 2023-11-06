import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/organisms/trace_map/index.dart';

class TraceMapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TraceMapPage'),
      ),
      body: TraceMapIndex(),
    );
  }
}
