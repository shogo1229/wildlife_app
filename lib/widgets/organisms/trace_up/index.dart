import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildlife_app/widgets/molecules/trace_up/footer.dart';
import 'package:wildlife_app/widgets/organisms/home/user_selection.dart';
import 'package:wildlife_app/widgets/organisms/trace_up/local_save.dart';

class TraceUpIndex extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int selectedUserId = context.watch<UserIdProvider>().selectedUserId;

    return Column(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Text(
            '選択したID: $selectedUserId',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 9,
          child: Local_Camera(),
        ),
        Expanded(
          flex: 1,
          child: TraceUpFooter(),
        ),
      ],
    );
  }
}
