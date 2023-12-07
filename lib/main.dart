import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:wildlife_app/util/firebase_options.dart';
import '../pages/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    color: Colors.white,
    home: new HomePage(),
  ));
}
