import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:wildlife_app/pages/login.dart';
import 'package:wildlife_app/pages/home.dart'; // ホームページのファイルをインポート
import 'package:wildlife_app/util/firebase_options.dart';

// ユーザーの認証情報を提供するプロバイダークラス
class UserProvider extends ChangeNotifier {
  User? _user;

  // ユーザーをセットしてリスナーに通知
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  // 現在のユーザーオブジェクトを取得
  User? getUser() {
    return _user;
  }

  // 現在のユーザーのUIDを文字列として取得するメソッドを追加
  String getUserId() => _user?.uid ?? '';
}

// アプリケーションのエントリーポイント
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebaseの初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // プロバイダーを使用して状態を管理するためのMultiProvider
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
}

// アプリケーション全体の設定
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
          AuthenticationWrapper(), // 認証の状態によって表示する画面を決定するAuthenticationWrapper
    );
  }
}

// AuthenticationWrapperクラス内のbuildメソッドの一部
class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // UserProviderの状態を取得
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.getUser();

    return StreamBuilder<User?>(
      // Firebase Authenticationの状態変更をリッスン
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          // Firebase Authenticationの状態が変更されたときに呼ばれる
          final firebaseUser = snapshot.data;

          if (firebaseUser != null) {
            // Firebaseにログイン済みの場合はUserProviderにセット
            userProvider.setUser(firebaseUser);
            print("ログイン済みです${firebaseUser.email} , ${firebaseUser.uid}");
            return HomePage();
          } else {
            // ログインしていない場合はログイン画面を表示
            return LoginPage();
          }
        }
        // ConnectionStateがactive以外の場合は何も表示しない
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
