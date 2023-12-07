import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:wildlife_app/widgets/organisms/trace_map/firebase_data.dart';

class GetFireBaseModel extends ChangeNotifier {
  List<FireBase_data> firebase_data = [];

  Future<void> fetchFirebase_data() async {
    final docs =
        await FirebaseFirestore.instance.collection('wildlife_trace').get();
    final firebase_data =
        docs.docs.map((doc) => FireBase_data.fromSnapshot(doc)).toList();
    this.firebase_data = firebase_data;
    notifyListeners();
  }
}
