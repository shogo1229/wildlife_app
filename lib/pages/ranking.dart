import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/organisms/ranking/ranking.dart';

class RankingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RankingPage'),
      ),
      body: Ranking(),
    );
  }
}
