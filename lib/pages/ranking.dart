import 'package:flutter/material.dart';

import 'package:wildlife_app/widgets/organisms/ranking/index.dart';

class RankingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RankingPage'),
      ),
      body: RankingIndex(),
    );
  }
}
