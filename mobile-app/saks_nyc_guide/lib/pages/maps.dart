import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

const styleString =
    "https://maps.geo.${region}.amazonaws.com/maps/v0/maps/${mapName}/style-descriptor?key=${apiKey}";
const apiKey =
    "v1.public.eyJqdGkiOiJhZWZjNTBhZC0xZWYzLTQwNjItYmE4Zi1kMDdmZjE2YTlmNDYifTc9rXnLgDt7iwHSnuW4-jpUKi5le1OALtiZVKmpOmsrpINiWzQwIoyHeymAvsYmqWoRXkTZQnOOoUEE9VA8etS1WRVXfyTFHhX17XNXKbWp2DoTabdAhEq6AJ3RrAMsXfNZrM0QQlFTvBcepwV9CH2mU3q8vHSm10TyS7ThOAZtAmBckpyR55R0D4ae90chKbClyGubPcq52ixMjm-q21Cvgv5RjjkK1EzzUKXG3lH0AtmwnY1mTG1Dmlf4ZNSxBfGGuihdpkgQNCT0hoIAR7vkKQdbrAFOieyzOOnmYUo4Tz52gk5IGSxAztWAw6YaUPPkHgg_ElbePzorNo46I_g.ZWU0ZWIzMTktMWRhNi00Mzg0LTllMzYtNzlmMDU3MjRmYTkx";
const mapName = "map-try-2";
const region = "us-east-1";
// enum OfflineDataState { unknown, downloaded, downloading, notDownloaded }

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Maps();
  }
}

class Maps extends StatefulWidget {
  const Maps({super.key});

  @override
  State createState() => MapState();
}

class MapState extends State<Maps> {
  MaplibreMapController? controller;

  void _onMapCreated(MaplibreMapController controller) {
    this.controller = controller;
  }

  bool _isPresent = true;

  Future<void> _fetchData(String type) async {
    AuthSession res = await Amplify.Auth.fetchAuthSession(
      options: CognitoSessionOptions(getAWSCredentials: true),
    );
    final idToken = (res as CognitoAuthSession).userPoolTokens!.idToken;

    controller!.clearSymbols();

    final Uri uri = Uri.parse(
        'https://u9rvp4d6qi.execute-api.us-east-1.amazonaws.com/v2/location_data?location_type=${type}');

    final http.Response response =
        await http.get(uri, headers: {"Authorization": idToken.raw});

    if (response.statusCode == 200) {
      try {
        // Parse the JSON response
        List<dynamic> res = jsonDecode(response.body);
        for (var element in res) {
          _addCustomMarker(
              "locationPin",
              LatLng(double.parse(element['Latitude']),
                  double.parse(element['Longitude'])));
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _addCustomMarker(String iconType, LatLng latLng) {
    controller!.addSymbol(_getSymbolOptions(iconType, latLng));
  }

  // void _addMarkers() {
  //   _isPresent = !_isPresent;
  //   if (_isPresent) {
  //     controller!.clearCircles();
  //     controller!.clearSymbols();
  //   } else {
  //     controller!.addSymbol(_getSymbolOptions("locationPin"));
  //     controller!.addCircle(
  //       const CircleOptions(
  //           geometry: LatLng(40.776676, -73.971321), circleColor: "#FF0000"),
  //     );
  //   }
  // }

  void _onStyleLoaded() {
    addImageFromAsset("locationPin", "assets/icons/location.png");
  }

  Future<void> addImageFromAsset(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return controller!.addImage(name, list);
  }

  SymbolOptions _getSymbolOptions(String iconImage, LatLng latLng) {
    LatLng geometry = latLng;
    return SymbolOptions(
      geometry: geometry,
      iconSize: 4.0,
      // textField: 'Roboto',
      // textOffset: const Offset(0, 0.8),
      iconImage: iconImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
      MaplibreMap(
          onMapCreated: _onMapCreated,
          onStyleLoadedCallback: _onStyleLoaded,
          styleString: styleString,
          myLocationEnabled: true,
          initialCameraPosition: const CameraPosition(
              target: LatLng(40.776676, -73.971321),
              zoom: 12.25,
              bearing: 28.5),
          dragEnabled: false,
          zoomGesturesEnabled: false,
          rotateGesturesEnabled: false,
          compassEnabled: false,
          cameraTargetBounds: CameraTargetBounds(LatLngBounds(
              northeast: const LatLng(40.800875, -73.914747),
              southwest: const LatLng(40.701539, -74.023967)))),
      Positioned(
          bottom: 20,
          right: 20,
          child: SpeedDial(
            animatedIcon: AnimatedIcons.menu_close,
            animatedIconTheme: IconThemeData(size: 28.0),
            backgroundColor: Colors.green[900],
            childrenButtonSize: const Size(60.0, 60.0),
            visible: true,
            curve: Curves.bounceInOut,
            children: [
              SpeedDialChild(
                child: const Icon(Icons.wc_rounded, color: Colors.white),
                backgroundColor: Colors.green,
                onTap: () => print('Pressed Restrooms'),
                label: 'Restrooms',
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.white),
                labelBackgroundColor: Colors.black,
                shape: const CircleBorder(),
              ),
              SpeedDialChild(
                child: const Icon(Icons.local_police_outlined,
                    color: Colors.white),
                backgroundColor: Colors.green,
                onTap: () => _fetchData("Precinct"),
                label: 'Police',
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.white),
                labelBackgroundColor: Colors.black,
                shape: const CircleBorder(),
              ),
              SpeedDialChild(
                child: const Icon(Icons.train_outlined, color: Colors.white),
                backgroundColor: Colors.green,
                onTap: () => _fetchData("Subway"),
                label: 'Subway',
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w500, color: Colors.white),
                labelBackgroundColor: Colors.black,
                shape: const CircleBorder(),
              ),
            ],
          ))
      // FloatingActionButton(onPressed: _addMarkers),
    ]));
  }
}
