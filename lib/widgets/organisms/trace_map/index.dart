import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/molecules/trace_map/footer.dart';
import 'package:wildlife_app/widgets/organisms/trace_map/get_firebase_data.dart';
import 'package:wildlife_app/widgets/organisms/trace_map/trace_map_firebase.dart';

class TraceMapIndex extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 6,
          child: FlutterMapFireBase(),
        ),
        Expanded(
          flex: 3,
          child: GetFirebase(),
        ),
        Expanded(
          flex: 1,
          child: TraceMapFooter(),
        ),
      ],
    );
  }
}
