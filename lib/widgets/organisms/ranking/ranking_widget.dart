import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/organisms/ranking/ranking.dart';

class WildlifeRankingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserRank>>(
      future: WildlifeRanking().getRanking(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('No ranking data available.'),
          );
        } else {
          List<UserRank> ranking = snapshot.data!;
          List<UserRank> boarRanking = List.from(ranking)
            ..sort((a, b) => b.boarPoint.compareTo(a.boarPoint));
          List<UserRank> deerRanking = List.from(ranking)
            ..sort((a, b) => b.deerPoint.compareTo(a.deerPoint));
          List<UserRank> totalRanking = List.from(ranking)
            ..sort((a, b) => b.totalPoint.compareTo(a.totalPoint));

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildRankingSection('Boar Point Ranking', boarRanking),
                buildRankingSection('Deer Point Ranking', deerRanking),
                buildRankingSection('Total Point Ranking', totalRanking),
              ],
            ),
          );
        }
      },
    );
  }

  Widget buildRankingSection(String title, List<UserRank> ranking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.0),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: ranking.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 3.0,
              margin: EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                title: Text(
                  'ユーザー ${ranking[index].user_id}: ${ranking[index].boarPoint} ポイント',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
