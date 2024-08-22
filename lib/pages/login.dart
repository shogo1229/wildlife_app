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
      body: Stack(
        children: <Widget>[
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/assets/images/bg_image.png"), // Add your image path here
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Foreground with form elements
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Email TextFormField with Icon
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'メールアドレス',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.mail),
                      ),
                      onChanged: (String value) {
                        setState(() {
                          _email = value;
                        });
                      },
                    ),
                  ),

                  // Password TextFormField with Icon
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'パスワード',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      onChanged: (String value) {
                        setState(() {
                          _password = value;
                        });
                      },
                    ),
                  ),

                  // Blue background, white text Login Button
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[900],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('ログイン'),
                    ),
                  ),

                  // White background, blue text Signup Button
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green[900],
                      ),
                      child: const Text('ユーザ登録'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
