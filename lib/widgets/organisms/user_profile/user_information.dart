import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:wildlife_app/main.dart';

class UserInformationMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UserInformationMenus(),
    );
  }
}

class UserInformationMenus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<UserProvider>(context).getUser();

    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('User_Information')
            .where('User_ID', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
            return Center(
              child: Text('User not found'),
            );
          }

          var userDocument =
              snapshot.data?.docs.first.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: <Widget>[
                _buildInfoCard('User Name', userDocument['User_Name']),
                _buildInfoCard('Total Point', userDocument['total_point']),
                _buildInfoCard('Boar Point', userDocument['Boar_Point']),
                _buildInfoCard('Deer Point', userDocument['Deer_Point']),
                _buildInfoCard('Other Point', userDocument['Other_Point']),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, dynamic value) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(value.toString()),
      ),
    );
  }
}
