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
          appBar: AppBar(
            title: Text('Latitude List'),
          ),
          body: Consumer<MainModel>(
            builder: (context, model, child) {
              final books = model.books;
              return ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(books[index].title),
                    subtitle: Text(
                      'Latitude: ${books[index].latitude}, Longitude: ${books[index].longitude}',
                    ),
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
