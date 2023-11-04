import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/atoms/footerButton.dart';
import 'package:wildlife_app/widgets/molecules/trace_up/footer.dart';
import 'package:wildlife_app/widgets/organisms/trace_up/camera.dart';
import 'package:wildlife_app/widgets/organisms/trace_up/simpleCamera.dart';

class TraceUpIndex extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: TraceCamera(),
        ),
        Expanded(
          child: TraceUpFooter(),
        ),
      ],
    );
  }
}
