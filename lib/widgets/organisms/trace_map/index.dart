import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/molecules/trace_map/footer.dart';
import 'package:wildlife_app/widgets/organisms/trace_map/get_firebase_data.dart';
import 'package:wildlife_app/widgets/organisms/trace_map/trace_map.dart';

class TraceMapIndex extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: FlutterMapWithLocation(),
        ),
        Expanded(
          child: GetFirebase(),
        ),
        Expanded(
          child: TraceMapFooter(),
        ),
      ],
    );
  }
}
