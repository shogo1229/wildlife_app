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
          List<UserRank> boarRanking = List.from(ranking)
            ..sort((a, b) => b.boarPoint.compareTo(a.boarPoint));
          List<UserRank> deerRanking = List.from(ranking)
            ..sort((a, b) => b.deerPoint.compareTo(a.deerPoint));
          List<UserRank> totalRanking = List.from(ranking)
            ..sort((a, b) => b.totalPoint.compareTo(a.totalPoint));
          return SingleChildScrollView(
            child: Column(
              children: [
                Text('Boar Point Ranking:'),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: boarRanking.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        'ユーザー ${boarRanking[index].user_id}: ${boarRanking[index].boarPoint} ポイント',
                      ),
                    );
                  },
                ),
                Text('Deer Point Ranking:'),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: deerRanking.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        'ユーザー ${deerRanking[index].user_id}: ${deerRanking[index].deerPoint} ポイント',
                      ),
                    );
                  },
                ),
                Text('Total Point Ranking:'),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: totalRanking.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        'ユーザー ${totalRanking[index].user_id}: ${totalRanking[index].totalPoint} ポイント',
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
