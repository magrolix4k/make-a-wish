import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../widgets/colors.dart';
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
  late LatLng destination;
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _marker = Set<Marker>();
  late String placeProvinces;
  late LocationData destinationLocation;
  late Location location;

  @override
  void initState() {
    super.initState();
    location = Location();
    double latitude = double.tryParse(widget.placeLatitude) ?? 0.0;
    double longitude = double.tryParse(widget.placeLongitude) ?? 0.0;
    destination = LatLng(latitude, longitude);
    placeProvinces = widget.placeProvince;
    showLocationPins();
  }

  void showLocationPins() {
    var sourcePosition = LatLng(destination.latitude, destination.longitude);

    _marker.add(Marker(
      markerId: MarkerId('sourcePosition'),
      position: sourcePosition,
    ));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    CameraPosition initialCameraPosition = CameraPosition(
      zoom: 17.5,
      target: destination,
    );

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
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
                          child: Icon(Icons.keyboard_arrow_left, color: Colors.white),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
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
                    markers: _marker,
                    mapType: MapType.normal,
                    initialCameraPosition: initialCameraPosition,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                      if (destination.latitude != 0.0 && destination.longitude != 0.0) {
                        showLocationPins();
                      }
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
}