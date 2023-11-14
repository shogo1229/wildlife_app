import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:wildlife_app/widgets/organisms/trace_map/book.dart';

class MainModel extends ChangeNotifier {
  List<Book> books = [];

  Future<void> fetchBooks() async {
    final docs =
        await FirebaseFirestore.instance.collection('wildlife_trace').get();
    final books = docs.docs.map((doc) => Book(doc)).toList();
    this.books = books;
    notifyListeners();
  }
}
