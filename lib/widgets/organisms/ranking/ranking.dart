
import 'package:cloud_firestore/cloud_firestore.dart';

class WildlifeRanking {
  Future<List<UserRank>> getRanking() async {
    try {
      // Firestoreからデータを取得
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('User_Information').get();

      // 取得したドキュメントをUserRankオブジェクトに変換し、リストに追加
      List<UserRank> ranking =
          querySnapshot.docs.map((doc) => UserRank.fromDocument(doc)).toList();

      // ポイントに基づいてランキングをソート
      ranking.sort((a, b) => b.totalPoint.compareTo(a.totalPoint));

      return ranking;
    } catch (e) {
      print('ランキングデータの取得エラー: $e');
      return [];
    }
  }
}

class UserRank {
  final int user_id;
  final int boarPoint;
  final int deerPoint;
  final int totalPoint;

  UserRank({
    required this.user_id,
    required this.boarPoint,
    required this.deerPoint,
    required this.totalPoint,
  });

  // FirestoreのドキュメントからUserRankオブジェクトを作成するファクトリメソッド
  factory UserRank.fromDocument(QueryDocumentSnapshot doc) {
    return UserRank(
      user_id: doc['User_ID'],
      boarPoint: doc['Boar_Point'],
      deerPoint: doc['Deer_Point'],
      totalPoint: doc['total_point'],
    );

  }
}
