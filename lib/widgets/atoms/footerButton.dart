import 'package:flutter/material.dart';

class NavigationButton extends StatelessWidget {
  final String icon;
  final bool enabled;
  final Widget? page;

  NavigationButton({
    required this.icon,
    required this.enabled,
    this.page,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled && page != null
          ? () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => page!));
            }
          : null,
      child: Text(icon),
    );
  }
}

class traceUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('traceUp Page'),
      ),
      body: Center(
        child: Text('traceUp Page Content'),
      ),
    );
  }
}

class traceMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('traceMap Page'),
      ),
      body: Center(
        child: Text('traceMap Page Content'),
      ),
    );
  }
}

class ranking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ranking Page'),
      ),
      body: Center(
        child: Text('Ranking Page Content'),
      ),
    );
  }
}

class userProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile Page'),
      ),
      body: Center(
        child: Text('User Profile Page Content'),
      ),
    );
  }
}
