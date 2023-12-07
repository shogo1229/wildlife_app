// trace_map_index.dart

import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/molecules/ranking/footer.dart';
import 'package:wildlife_app/widgets/organisms/ranking/ranking_widget.dart';

class RankingIndex extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 9,
          child: WildlifeRankingWidget(),
        ),
        Expanded(
          flex: 1,
          child: RankingFooter(), // Assuming you have this widget defined
        ),
      ],
    );
  }
}
