import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:wildlife_app/widgets/organisms/trace_map/FireBase_Data.dart';

class FireBase_data {
  final String title;
  final double latitude;
  final double longitude;

  FireBase_data({
    required this.title,
    required this.latitude,
    required this.longitude,
  });

  // nullの場合にデフォルト値を使用するように更新されたコンストラクタ
  FireBase_data.fromSnapshot(DocumentSnapshot snapshot)
      : title = snapshot['url'] ?? '', // タイトルは必ず存在すると仮定し、存在しない場合は空文字列を設定
        latitude = (snapshot['latitude'] as double?) ?? 0.0,
        longitude = (snapshot['longitude'] as double?) ?? 0.0;
}
