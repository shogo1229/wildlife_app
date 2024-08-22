import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:wildlife_app/widgets/organisms/home/firebase/FireBase_Data.dart';

class GetFireBaseModel extends ChangeNotifier {
  List<FireBase_data> firebase_data = [];

  Future<void> fetchFirebase_data(String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('wildlife_trace')
          .where('User_ID', isEqualTo: userId)
          .get();

      final data = querySnapshot.docs
          .map((doc) => FireBase_data.fromSnapshot(doc))
          .toList();

      this.firebase_data = data;
      notifyListeners();
    } catch (e) {
      print('Error fetching data from Firebase: $e');
    }
  }
}
