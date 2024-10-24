// app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildlife_app/widgets/organisms/home/firebase/get_firebase_model.dart';

class GetFirebase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider<GetFireBaseModel>(
        create: (_) => GetFireBaseModel()..fetchFirebase_data(),
        child: Scaffold(
          body: Consumer<GetFireBaseModel>(
            builder: (context, model, child) {
              final firebase_data = model.firebase_data;
              return ListView.builder(
                itemCount: firebase_data.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Image.network(firebase_data[index].title), // 画像を表示
                    subtitle: Text(
                      'Latitude: ${firebase_data[index].latitude}, Longitude: ${firebase_data[index].longitude}',
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
