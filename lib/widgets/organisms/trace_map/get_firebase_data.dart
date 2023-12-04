// app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildlife_app/widgets/organisms/trace_map/get_firebase_model.dart';

class GetFirebase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider<GetFireBaseModel>(
        create: (_) => GetFireBaseModel()..fetchFirebase_data(),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Latitude List'),
          ),
          body: Consumer<GetFireBaseModel>(
            builder: (context, model, child) {
              final firebase_data = model.firebase_data;
              return ListView.builder(
                itemCount: firebase_data.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(firebase_data[index].title),
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
