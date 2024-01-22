import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/molecules/trace_up/footer.dart';
import 'package:wildlife_app/widgets/organisms/trace_up/camera_main.dart';

class TraceUpIndex extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 9,
          child: Call_LocalCamera(),
        ),
        Expanded(
          flex: 1,
          child: TraceUpFooter(),
        ),
      ],
    );
  }
}
