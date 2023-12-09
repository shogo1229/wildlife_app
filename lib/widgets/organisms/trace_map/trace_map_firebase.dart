import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:wildlife_app/widgets/organisms/trace_map/get_firebase_model.dart'; // Added this line

void main() => runApp(MaterialApp(home: FlutterMapFireBase()));

class FlutterMapFireBase extends StatefulWidget {
  @override
  _FlutterMapWithLocationState createState() => _FlutterMapWithLocationState();
}

class _FlutterMapWithLocationState extends State<FlutterMapFireBase> {
  final MapController mapController = MapController();
  LatLng currentLocation = LatLng(0, 0);
  String currentLocationText = 'Loading...';

  Location location = Location();

  GetFireBaseModel firebaseModel = GetFireBaseModel(); // Added this line

  @override
  void initState() {
    super.initState();
    getLocation().then((_) {
      mapController.move(currentLocation, 16.0);
    });
    firebaseModel.fetchFirebase_data();

    // Subscribe to location changes
    location.onLocationChanged.listen((LocationData? newLocation) {
      setState(() {
        if (newLocation != null) {
          currentLocation =
              LatLng(newLocation.latitude!, newLocation.longitude!);
          currentLocationText =
              'Latitude: ${newLocation.latitude}, Longitude: ${newLocation.longitude}';
        }
      });
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
        // currentLocationText =
        //     'Latitude: ${_locationData.latitude}, Longitude: ${_locationData.longitude}';
      });
    }
  }

  void warpToCurrentLocation() {
    mapController.move(currentLocation, 16.0);
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
                  zoom: 0.0,
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
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: currentLocation,
                        width: 200,
                        height: 200,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 50,
                        ),
                      ),
                      ...firebaseModel.firebase_data.map((data) => Marker(
                          point: LatLng(data.latitude, data.longitude),
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    child: Image.network(data.title),
                                  );
                                },
                              );
                            },
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.red,
                            ),
                          ))),
                    ],
                  ),
                ],
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.all(16.0),
            //   child: Text(currentLocationText),
            // ),
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
