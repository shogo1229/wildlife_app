// wildlife_ranking_widget.dart

import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/organisms/ranking/ranking.dart';

class WildlifeRankingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserRank>>(
      future: WildlifeRanking().getRanking(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Add a loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No ranking data available.');
        } else {
          // Display the ranking using snapshot.data
          List<UserRank> ranking = snapshot.data!;
          return ListView.builder(
            itemCount: ranking.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  'ユーザー ${ranking[index].user_id}: ${ranking[index].totalPoint} ポイント',
                ),
              );
            },
          );
        }
      },
    );
  }
}
