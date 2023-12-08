import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/molecules/trace_up/footer.dart';
import 'package:wildlife_app/widgets/organisms/trace_up/local_save.dart';

class TraceUpIndex extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 9, // adjust the flex values as needed
          child: Local_Camera(),
        ),
        Expanded(
          flex: 1, // adjust the flex values as needed
          child: TraceUpFooter(),
        ),
      ],
    );
  }
}
