import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/molecules/home/footer.dart';
import 'package:wildlife_app/widgets/organisms/home/trace_map.dart';
import 'package:wildlife_app/widgets/organisms/home/user_selection.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedUserId = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: userID_select(),
        ),
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
