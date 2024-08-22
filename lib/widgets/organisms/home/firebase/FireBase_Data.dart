import 'package:cloud_firestore/cloud_firestore.dart';

class FireBase_data {
  String title;
  String animalType; // Added property
  double latitude;
  double longitude;

  FireBase_data({
    required this.title,
    required this.animalType, // Added this line
    required this.latitude,
    required this.longitude,
  });

  // DocumentSnapshotからFireBase_dataを作成するためのファクトリコンストラクタ
  factory FireBase_data.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      // データがnullの場合は適切に処理するか、例外を投げるなどしてください
      throw Exception("ドキュメントデータはnullです");
    }

    return FireBase_data(
      title: data['url'] ?? '', // 'title'がnullの場合はデフォルト値を提供
      animalType: data['AnimalType'] ?? '', // 'AnimalType'がnullの場合はデフォルト値を提供
      latitude: data['latitude'] ?? 0.0, // 'latitude'がnullの場合はデフォルト値を提供
      longitude: data['longitude'] ?? 0.0, // 'longitude'がnullの場合はデフォルト値を提供
    );
  }
}
