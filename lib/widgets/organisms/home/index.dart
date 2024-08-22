import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/molecules/home/footer.dart';
import 'package:wildlife_app/widgets/organisms/home/map/trace_map_boar.dart';
import 'package:wildlife_app/widgets/organisms/home/map/trace_map_deer.dart';
import 'package:wildlife_app/widgets/organisms/home/map/trace_map_firebase.dart';



class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: <Widget>[
          const TabBar(
            labelColor: Colors.green, // Set the text color for selected tab
            unselectedLabelColor:
                Colors.grey, // Set the text color for unselected tabs
            indicatorColor: Colors.green, // Set the color of the indicator
            tabs: [
              Tab(text: '全て表示'),
              Tab(text: 'イノシシ'),
              Tab(text: 'ニホンジカ'),
            ],
          ),
          Expanded(
            flex: 6,
            child: TabBarView(
              children: [
                FlutterMapFireBase(),
                FlutterMAP_Boar(),
                FlutterMAP_Deer(),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: HomeFooter(),
          ),
        ],
      ),
    );
  }
}
