import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class flutterMAP extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MapController mapController = MapController();
    final LatLng initialLocation =
        LatLng(35.682839, 139.759455); // 初期の緯度経度情報を設定

    return MaterialApp(
      home: Scaffold(
        body: FlutterMap(
          // マップ表示設定
          options: const MapOptions(
            center: LatLng(35.681, 139.767),
            zoom: 14.0,
            interactiveFlags: InteractiveFlag.all,
            enableScrollWheel: true,
            scrollWheelVelocity: 0.00001,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.jp/{z}/{x}/{y}.png",
              userAgentPackageName: 'land_place',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // 特定の緯度経度に移動する
            mapController.move(initialLocation, 15.0);
          },
          child: Icon(Icons.gps_fixed),
        ),
      ),
    );
  }
}
