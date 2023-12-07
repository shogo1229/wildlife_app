import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/molecules/home/footer.dart';
import 'package:wildlife_app/widgets/organisms/home/trace_map.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 7,
          child: FlutterMapFireBase(),
        ),
        Expanded(
          flex: 1,
          child: HomeFooter(),
        ),
      ],
    );
  }
}
