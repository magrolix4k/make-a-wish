import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../utils/colors.dart';
import '../widgets/ReuseableText.dart';

class GotoGate extends StatefulWidget {
  final String placeId;
  final String placeProvince;
  final String placeLatitude;
  final String placeLongitude;

  GotoGate({
    Key? key,
    required this.placeId,
    required this.placeProvince,
    required this.placeLatitude,
    required this.placeLongitude,
  }) : super(key: key);

  @override
  State<GotoGate> createState() => _GotoGateState();
}

class _GotoGateState extends State<GotoGate> {
  LatLng sourceLocation = LatLng(13.758616637758408, 100.51298654467398);
  late LatLng destination;

  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _marker = Set<Marker>();

  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;

  late StreamSubscription<LocationData> subscription;

  LocationData? currentLocation;
  late String placeProvinces;
  late LocationData destinationLocation;
  late Location location;

  @override
  void initState() {
    super.initState();

    location = Location();
    polylinePoints = PolylinePoints();

    subscription = location.onLocationChanged.listen((clocation) {
      currentLocation = clocation;

      updatePinsOnMap();
    });
    destination = LatLng(
      double.parse(widget.placeLatitude),
      double.parse(widget.placeLongitude),
    );
    placeProvinces = widget.placeProvince;
    setInitialLocation();
  }

  void setInitialLocation() async {
    await location.getLocation().then((value) {
      currentLocation = value;
      setState(() {});
    });

    destinationLocation = LocationData.fromMap({
      "latitude": destination.latitude,
      "longitude": destination.longitude,
    });
  }

  void showLocationPins() {
    var sourcePosition = LatLng(
      currentLocation!.latitude ?? 0.0,
      currentLocation!.longitude ?? 0.0,
    );

    var destinationPosition = destination;

    _marker.add(Marker(
      markerId: MarkerId('sourcePosition'),
      position: sourcePosition,
    ));

    _marker.add(
      Marker(
        markerId: MarkerId('destinationPosition'),
        position: destinationPosition,
      ),
    );

    setState(() {
      polylineCoordinates.clear();
      _polylines.clear();
    });

    setPolylinesInMap();
  }

  void updatePinsOnMap() async {
    CameraPosition cameraPosition = CameraPosition(
      zoom: 17.5,
      target: LatLng(
          currentLocation!.latitude ?? 0.0, currentLocation!.longitude ?? 0.0),
    );

    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    var sourcePosition = LatLng(
        currentLocation!.latitude ?? 0.0, currentLocation!.longitude ?? 0.0);

    setState(() {
      _marker
          .removeWhere((marker) => marker.markerId.value == 'sourcePosition');
      _marker.add(Marker(
        markerId: MarkerId('sourcePosition'),
        position: sourcePosition,
      ));
    });

    // setPolylinesInMap();
  }

  void setPolylinesInMap() async {
    var result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyCm-vn11K2D3HvdLgz5jiu3OiJTZXw1LtU',
      PointLatLng(
          currentLocation!.latitude ?? 0.0, currentLocation!.longitude ?? 0.0),
      PointLatLng(destination.latitude, destination.longitude),
    );

    setState(() {
      _polylines.clear();
    });

    if (result.points.isNotEmpty) {
      result.points.forEach((pointLatLng) {
        polylineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setState(() {
      _polylines.add(Polyline(
        width: 5,
        polylineId: PolylineId('polyline'),
        color: Colors.blueAccent,
        points: polylineCoordinates,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    CameraPosition initialCameraPosition = CameraPosition(
      zoom: 17.5,
      target: currentLocation != null
          ? LatLng(currentLocation!.latitude ?? 0.0,
              currentLocation!.longitude ?? 0.0)
          : LatLng(0.0, 0.0),
    );

    return currentLocation == null
        ? Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          )
        : SafeArea(
            child: Scaffold(
              body: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: screenWidth * 0.1,
                                height: screenWidth * 0.1,
                                child: Icon(Icons.keyboard_arrow_left,
                                    color: Colors.white),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(screenWidth * 0.03),
                                  color: AppColors.mainColor,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                ReusableText(
                                  text: "เส้นทางไปยัง.." + placeProvinces,
                                  color: AppColors.mainColor,
                                  size: screenWidth * 0.06,
                                  alignment: Alignment.center,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Align(
                        child: GoogleMap(
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          markers: _marker,
                          polylines: _polylines,
                          mapType: MapType.normal,
                          initialCameraPosition: initialCameraPosition,
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                            showLocationPins();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
