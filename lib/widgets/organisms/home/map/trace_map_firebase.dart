import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:wildlife_app/widgets/organisms/home/firebase/get_firebase_model.dart';

void main() => runApp(MaterialApp(home: FlutterMapFireBase()));

class FlutterMapFireBase extends StatefulWidget {
  @override
  _FlutterMapWithLocationState createState() => _FlutterMapWithLocationState();
}

class _FlutterMapWithLocationState extends State<FlutterMapFireBase> {
  final MapController mapController = MapController();
  LatLng currentLocation = LatLng(0, 0);
  String currentLocationText = 'Loading...';
  bool isLocationLoading = true;
  bool isMapLoading = true; // Map loading state
  bool isMapLoaded = false; // Map fully loaded flag
  Timer? retryTimer; // Timer to retry loading the map

  Location location = Location();
  GetFireBaseModel firebaseModel = GetFireBaseModel();

  @override
  void initState() {
    super.initState();

    // Get user location and update map position
    getLocation().then((_) {
      if (mounted) {
        setState(() {
          mapController.move(currentLocation, 16.0);
          isLocationLoading = false;
        });
      }
    });

    // Fetch Firebase data for the user
    fetchUserSpecificData();

    // Listen for location changes
    location.onLocationChanged.listen((LocationData? newLocation) {
      if (mounted) {
        setState(() {
          if (newLocation != null) {
            currentLocation =
                LatLng(newLocation.latitude!, newLocation.longitude!);
            currentLocationText =
                'Latitude: ${newLocation.latitude}, Longitude: ${newLocation.longitude}';
          }
        });
      }
    });

    // Start retry timer to reload the map if necessary
    startRetryTimer();
  }

  @override
  void dispose() {
    retryTimer?.cancel();
    super.dispose();
  }

  Future<void> getLocation() async {
    LocationData? _locationData;
    try {
      _locationData = await location.getLocation();
    } catch (e) {
      debugPrint('Failed to get location: $e');
    }

    if (_locationData != null) {
      setState(() {
        currentLocation =
            LatLng(_locationData!.latitude!, _locationData!.longitude!);
        isLocationLoading = false; // Set location loading to false after getting the location
      });
    }
  }

  Future<void> fetchUserSpecificData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await firebaseModel.fetchFirebase_data(user.uid); // Fetch data with User_ID
    }
  }

  void startRetryTimer() {
    retryTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (!isMapLoaded) {
        debugPrint('Attempting to reload the map...');
        setState(() {
          isMapLoading = false;
          isMapLoaded = true;
        });
        fetchUserSpecificData();
      }
    });
  }

  void warpToCurrentLocation() {
    mapController.move(currentLocation, 16.0);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                center: currentLocation,
                zoom: 16.0,
                interactiveFlags: InteractiveFlag.all,
                enableScrollWheel: true,
                scrollWheelVelocity: 0.00001,
                onMapReady: () {
                  setState(() {
                    isMapLoading = false; // Set map loading to false once map is ready
                    isMapLoaded = true; // Map is fully loaded
                    retryTimer?.cancel(); // Stop retrying when map is loaded
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://tile.openstreetmap.jp/{z}/{x}/{y}.png",
                  userAgentPackageName: 'land_place',
                  errorTileCallback: (tile, error, stackTrace) {
                    debugPrint('Failed to load OSM tile: $error');
                    setState(() {
                      isMapLoading = true; // Set map loading failure
                    });
                  },
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
                    if (isMapLoaded) // Show markers only after the map is loaded
                      ...firebaseModel.firebase_data.map((data) {
                        Widget markerImage;
                        if (data.animalType == 'Boar') {
                          markerImage = Image.asset(
                            'lib/assets/images/Boar_pin_Normal.png',
                            width: 20,
                            height: 20,
                          );
                        } else if (data.animalType == 'Deer') {
                          markerImage = Image.asset(
                            'lib/assets/images/Deer_pin_Normal.png',
                            width: 20,
                            height: 20,
                          );
                        } else {
                          markerImage = Image.asset(
                            'lib/assets/images/Other_pin_Normal.png',
                            width: 20,
                            height: 20,
                          );
                        }

                        return Marker(
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
                                      color: Colors.grey,
                                      child: Center(
                                        child: Container(
                                          padding: EdgeInsets.all(16.0),
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'Latitude: ${data.latitude}',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    'Longitude: ${data.longitude}',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                  SizedBox(height: 16),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
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
                            child: markerImage,
                          ),
                        );
                      }),
                  ],
                ),
              ],
            ),
            if (isLocationLoading || isMapLoading) // Display cover if location or map is loading
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 18),
                      Text(
                        '現在地を取得中です。電波状況が悪い場合、現在地や地図は表示されません。',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: warpToCurrentLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green[900],
                ),
                child: Text('現在地に移動'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
