import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/molecules/trace_map/footer.dart';
import 'package:wildlife_app/widgets/organisms/trace_map/trace_map.dart';
import 'package:wildlife_app/widgets/organisms/trace_map/trace_map_firebase.dart';

class TraceMapIndex extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: FlutterMapWithLocation(),
        ),
        Expanded(
          child: TracePinMap(),
        ),
        Expanded(
          child: TraceMapFooter(),
        ),
      ],
    );
  }
}
