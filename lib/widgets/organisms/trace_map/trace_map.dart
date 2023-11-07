import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

void main() => runApp(MaterialApp(home: FlutterMapWithLocation()));

class FlutterMapWithLocation extends StatefulWidget {
  @override
  _FlutterMapWithLocationState createState() => _FlutterMapWithLocationState();
}

class _FlutterMapWithLocationState extends State<FlutterMapWithLocation> {
  final MapController mapController = MapController();
  LatLng currentLocation = LatLng(0, 0);
  String currentLocationText = 'Loading...';

  Location location = Location();

  @override
  void initState() {
    super.initState();
    // アプリが起動した瞬間に現在の位置を取得
    getLocation().then((_) {
      // 現在の位置を初期の地図の中心位置として設定
      mapController.move(currentLocation, 14.0);
    });
  }

  Future<void> getLocation() async {
    LocationData? _locationData; // nullableとして初期化
    try {
      _locationData = await location.getLocation();
    } catch (e) {
      print('Failed to get location: $e');
    }

    if (_locationData != null) {
      setState(() {
        currentLocation =
            LatLng(_locationData!.latitude!, _locationData.longitude!);
        currentLocationText =
            'Latitude: ${_locationData.latitude}, Longitude: ${_locationData.longitude}';
      });
    }
  }

  void warpToCurrentLocation() {
    mapController.move(currentLocation, 14.0);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  center: currentLocation,
                  zoom: 14.0,
                  interactiveFlags: InteractiveFlag.all,
                  enableScrollWheel: true,
                  scrollWheelVelocity: 0.00001,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.jp/{z}/{x}/{y}.png",
                    userAgentPackageName: 'land_place',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                        point: currentLocation,
                        width: 40,
                        height: 40,
                        child: FlutterLogo())
                  ])
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(currentLocationText),
            ),
            ElevatedButton(
              onPressed: warpToCurrentLocation,
              child: Text('Warp to Current Location'),
            ),
          ],
        ),
      ),
    );
  }
}
