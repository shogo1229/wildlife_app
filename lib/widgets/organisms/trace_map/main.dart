// app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildlife_app/widgets/organisms/trace_map/main_model.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider<MainModel>(
        create: (_) => MainModel()..fetchBooks(),
        child: Scaffold(
          body: Consumer<MainModel>(
            builder: (context, model, child) {
              final books = model.books;
              return ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(books[index].title),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
