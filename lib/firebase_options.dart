// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAu7sioErNBAmBJZQKWznfk-DvgDY4jsWE',
    appId: '1:364333860786:web:454ad65921ee13db5dc6ab',
    messagingSenderId: '364333860786',
    projectId: 'wildlife-app-f67c3',
    authDomain: 'wildlife-app-f67c3.firebaseapp.com',
    storageBucket: 'wildlife-app-f67c3.appspot.com',
    measurementId: 'G-LHXXFST4R8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBgly3wMdEoYcAWM8CJG0ZnQpzyAOnJE48',
    appId: '1:364333860786:android:b09dbd239a0d9e3c5dc6ab',
    messagingSenderId: '364333860786',
    projectId: 'wildlife-app-f67c3',
    storageBucket: 'wildlife-app-f67c3.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyALDmgZYSNKTffGxCdC1nAU1XXq9unOld4',
    appId: '1:364333860786:ios:e70a8f93a42e4b795dc6ab',
    messagingSenderId: '364333860786',
    projectId: 'wildlife-app-f67c3',
    storageBucket: 'wildlife-app-f67c3.appspot.com',
    iosBundleId: 'com.example.wildlifeApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyALDmgZYSNKTffGxCdC1nAU1XXq9unOld4',
    appId: '1:364333860786:ios:e70a8f93a42e4b795dc6ab',
    messagingSenderId: '364333860786',
    projectId: 'wildlife-app-f67c3',
    storageBucket: 'wildlife-app-f67c3.appspot.com',
    iosBundleId: 'com.example.wildlifeApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAu7sioErNBAmBJZQKWznfk-DvgDY4jsWE',
    appId: '1:364333860786:web:a966d1d44d20ee815dc6ab',
    messagingSenderId: '364333860786',
    projectId: 'wildlife-app-f67c3',
    authDomain: 'wildlife-app-f67c3.firebaseapp.com',
    storageBucket: 'wildlife-app-f67c3.appspot.com',
    measurementId: 'G-7NZHHCX0MS',
  );
}
