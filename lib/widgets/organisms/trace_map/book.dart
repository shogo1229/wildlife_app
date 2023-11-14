import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  String title = ''; // または任意のデフォルト値
  Book(DocumentSnapshot doc) {
    title = doc['latitude'];
  }
}
