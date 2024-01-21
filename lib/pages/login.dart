import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:wildlife_app/main.dart';
import 'package:wildlife_app/pages/home.dart';
import 'package:wildlife_app/widgets/organisms/login/signup_form.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email = '';
  String _password = '';

  Future<void> _showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'メールアドレス'),
                onChanged: (String value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'パスワード'),
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    _password = value;
                  });
                },
              ),
              ElevatedButton(
                child: const Text('ユーザ登録'),
                onPressed: () async {
                  try {
                    final User? user = (await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                                email: _email, password: _password))
                        .user;
                    if (user != null) {
                      print("ユーザ登録しました ${user.email} , ${user.uid}");
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => RegistrationPage(),
                        ),
                      );
                    }
                  } catch (e) {
                    print(e);
                    _showErrorDialog("ユーザー登録エラー: $e");
                  }
                },
              ),
              ElevatedButton(
                child: const Text('ログイン'),
                onPressed: () async {
                  try {
                    final User? user = (await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: _email, password: _password))
                        .user;
                    if (user != null) {
                      Provider.of<UserProvider>(context, listen: false)
                          .setUser(user);
                      print("ログインしました　${user.email} , ${user.uid}");
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                      );
                    }
                  } catch (e) {
                    print(e);
                    _showErrorDialog("$e");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
