import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:wildlife_app/widgets/organisms/home/firebase/get_firebase_model.dart';

class FlutterMAP_Deer extends StatefulWidget {
  @override
  _FlutterMapWithLocationState createState() => _FlutterMapWithLocationState();
}

class _FlutterMapWithLocationState extends State<FlutterMAP_Deer> {
  final MapController mapController = MapController();
  LatLng currentLocation = LatLng(0, 0);
  String currentLocationText = 'Loading...';

  Location location = Location();

  GetFireBaseModel firebaseModel = GetFireBaseModel();

  @override
  void initState() {
    super.initState();
    getLocation().then((_) {
      mapController.move(currentLocation, 16.0);
    });

    fetchUserSpecificData(); // Fetch data with User_ID

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
    LocationData? _locationData;
    try {
      _locationData = await location.getLocation();
    } catch (e) {
      print('Failed to get location: $e');
    }

    if (_locationData != null) {
      setState(() {
        currentLocation =
            LatLng(_locationData!.latitude!, _locationData.longitude!);
      });
    }
  }

  Future<void> fetchUserSpecificData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await firebaseModel.fetchFirebase_data(user.uid); // Pass the user ID to fetchFirebase_data
    }
  }

  List<Marker> getFilteredMarkers() {
    return firebaseModel.firebase_data
        .where((data) => data.animalType == 'Deer')
        .map((data) => Marker(
              point: LatLng(data.latitude, data.longitude),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.all(16.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                        data.title,
                                        height: 500,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Animal Type: ${data.animalType}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Latitude: ${data.latitude}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Longitude: ${data.longitude}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('閉じる'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Image.asset(
                  'lib/assets/images/Deer_pin_Normal.png',
                  width: 40,
                  height: 40,
                ),
              ),
            ))
        .toList();
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
                      ...getFilteredMarkers(),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity, // ボタンを画面いっぱいに広げる
              child: ElevatedButton(
                onPressed: warpToCurrentLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green[900],
                ),
                child: Text('現在地に移動'),
              ),
            )

          ],
        ),
      ),
    );
  }
}
