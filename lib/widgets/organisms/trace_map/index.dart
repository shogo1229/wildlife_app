import 'package:flutter/material.dart';
import 'package:wildlife_app/widgets/molecules/trace_map/footer.dart';
import 'package:wildlife_app/widgets/organisms/trace_map/trace_map_boar.dart';
import 'package:wildlife_app/widgets/organisms/trace_map/trace_map_deer.dart';
import 'package:wildlife_app/widgets/organisms/trace_map/trace_map_firebase.dart';

class TraceMapIndex extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: <Widget>[
          const TabBar(
            labelColor: Colors.black, // Set the text color for selected tab
            unselectedLabelColor:
                Colors.grey, // Set the text color for unselected tabs
            indicatorColor: Colors.grey, // Set the color of the indicator
            tabs: [
              Tab(text: 'Total'),
              Tab(text: 'Boar'),
              Tab(text: 'Deer'),
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
            child: TraceMapFooter(),
          ),
        ],
      ),
    );
  }
}
