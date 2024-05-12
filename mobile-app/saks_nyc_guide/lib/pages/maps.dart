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
import 'package:aws_client/location_2020_11_19.dart' as aws_location;

const styleString =
    "https://maps.geo.${region}.amazonaws.com/maps/v0/maps/${mapName}/style-descriptor?key=${apiKey}";
const apiKey =
    "v1.public.eyJqdGkiOiJhZWZjNTBhZC0xZWYzLTQwNjItYmE4Zi1kMDdmZjE2YTlmNDYifTc9rXnLgDt7iwHSnuW4-jpUKi5le1OALtiZVKmpOmsrpINiWzQwIoyHeymAvsYmqWoRXkTZQnOOoUEE9VA8etS1WRVXfyTFHhX17XNXKbWp2DoTabdAhEq6AJ3RrAMsXfNZrM0QQlFTvBcepwV9CH2mU3q8vHSm10TyS7ThOAZtAmBckpyR55R0D4ae90chKbClyGubPcq52ixMjm-q21Cvgv5RjjkK1EzzUKXG3lH0AtmwnY1mTG1Dmlf4ZNSxBfGGuihdpkgQNCT0hoIAR7vkKQdbrAFOieyzOOnmYUo4Tz52gk5IGSxAztWAw6YaUPPkHgg_ElbePzorNo46I_g.ZWU0ZWIzMTktMWRhNi00Mzg0LTllMzYtNzlmMDU3MjRmYTkx";
const mapName = "saks-map-1";
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

  List<SymbolOptions> _markers = [];

  bool _isPresent = true;

  void _fetchRouteMap() async {
    controller!.clearLines();
    final location = aws_location.Location(
        region: 'us-east-1',
        endpointUrl: 'https://routes.geo.us-east-1.amazonaws.com',
        credentials: aws_location.AwsClientCredentials(
            accessKey: "AKIA6ODU7NUJVR6VAQ4Q",
            secretKey: "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"));
    final locationTry = location.calculateRoute(
        travelMode: aws_location.TravelMode.car,
        includeLegGeometry: true,
        calculatorName: "saks-route-calculator-2",
        departurePosition: [
          -74.010934,
          40.713359
        ],
        waypointPositions: [
          [-73.959472, 40.817046]
        ],
        destinationPosition: [
          -73.984852,
          40.732349
        ]);
    locationTry.then((value) {
      var routeList = value.toJson();
      List<aws_location.Leg> legs = routeList['Legs'];
      List<LineOptions> lineList = [];
      for (var leg in legs) {
        List<dynamic> lines = (leg.toJson()['Geometry'].toJson()['LineString']);
        for (int i = 0; i < lines.length - 1; i++) {
          LineOptions line =
              LineOptions(lineColor: "#0000FF", lineWidth: 3, geometry: [
            LatLng(lines[i][1], lines[i][0]),
            LatLng(lines[i + 1][1], lines[i + 1][0]),
          ]);
          lineList.add(line);
        }
        // List<aws_location.Step> steps = leg.toJson()['Steps'];
        // for (var step in steps) {
        //   print(step.toJson());
        //   LineOptions line =
        //       LineOptions(lineColor: "#0000FF", lineWidth: 3, geometry: [
        //     LatLng(step.endPosition[1], step.endPosition[0]),
        //     LatLng(step.startPosition[1], step.startPosition[0])
        //   ]);
        //   controller!.addLines([line]);
        // }
      }
      controller!.addLines(lineList);
    });
  }

  Future<void> _fetchData(String type) async {
    AuthSession res = await Amplify.Auth.fetchAuthSession(
      options: CognitoSessionOptions(getAWSCredentials: true),
    );
    final idToken = (res as CognitoAuthSession).userPoolTokens!.idToken;

    controller!.clearSymbols();
    _markers.clear();
    final Uri uri = Uri.parse(
        'https://u9rvp4d6qi.execute-api.us-east-1.amazonaws.com/v3/location_data?location_type=${type}');

    final http.Response response =
        await http.get(uri, headers: {"Authorization": idToken.raw});

    if (response.statusCode == 200) {
      try {
        List<dynamic> res = jsonDecode(response.body);
        for (var element in res) {
          _markers.add(_getSymbolOptions(
              type,
              LatLng(element['Latitude'],
                  element['Longitude'])));
        }
        controller!.addSymbols(_markers);
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
    addImageFromAsset("Citibike", "assets/icons/Citibike.png");
    addImageFromAsset("currentLocation", "assets/icons/current_location.png");
    addImageFromAsset("Precinct", "assets/icons/Precinct.png");
    addImageFromAsset("Restroom", "assets/icons/Restroom.png");
    addImageFromAsset("Subway", "assets/icons/Subway.png");
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
      iconSize: 0.4,
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
                onTap: () => _fetchRouteMap(),
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
                child: const Icon(Icons.pedal_bike_outlined,
                    color: Colors.white),
                backgroundColor: Colors.green,
                onTap: () => _fetchData("Citibike"),
                label: 'CitiBike',
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
