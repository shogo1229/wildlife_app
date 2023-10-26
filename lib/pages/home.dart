import 'package:flutter/material.dart';
import 'ranking.dart';
import 'trace_map.dart';
import 'trace_up.dart';
import 'user_profile.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AppHome(),
  ));
}

class AppHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter ページ遷移の例'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const ElevatedButton(
              onPressed: null,
              child: Text('ページ 1 に遷移'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => traceUp()));
              },
              child: Text('ページ 2 に遷移'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => traceMap()));
              },
              child: Text('ページ 3 に遷移'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ranking()));
              },
              child: Text('ページ 4 に遷移'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => userProfile()));
              },
              child: Text('ページ 5 に遷移'),
            ),
          ],
        ),
      ),
    );
  }
}
