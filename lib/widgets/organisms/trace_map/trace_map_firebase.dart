import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: TracePinMap()));

class TracePinMap extends StatefulWidget {
  @override
  _TracePinMapState createState() => _TracePinMapState();
}

class _TracePinMapState extends State<TracePinMap> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final query = await _db.collection("users").where("userId", isEqualTo: firebaseUser.uid).get();
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('wildlife_trace');
  late Stream<QuerySnapshot> _userStream;
  List<String> wildlifeData = [];

  @override
  void initState() {
    super.initState();

    _userStream = _users.snapshots();

    _userStream.listen((QuerySnapshot snapshot) {
      final List<String> data = [];
      for (final QueryDocumentSnapshot document in snapshot.docs) {
        final latitude = document['latitude'] as double;
        final longitude = document['longitude'] as double;
        data.add('Latitude: $latitude, Longitude: $longitude');
      }
      setState(() {
        wildlifeData = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Wildlife Data:"),
                  Column(
                    children: wildlifeData.map((data) => Text(data)).toList(),
                  ),
                ], 
              ),
            ),
          ],
        ),
      ),
    );
  }
}


