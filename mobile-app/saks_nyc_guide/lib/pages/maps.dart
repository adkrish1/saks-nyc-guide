import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

const styleString = "https://maps.geo.${region}.amazonaws.com/maps/v0/maps/${mapName}/style-descriptor?key=${apiKey}";
const apiKey = "v1.public.eyJqdGkiOiIwMTZiOTlhYS01NWJhLTQ0OGQtODAxYy1lMjYxMmMzMzY2YTkifTg4rxHJFQ1Sgbe7o0XHzJwWCqD86oR0rO1MjPjh6XiTOmKUwvXIw66TUxmm80LnQW7zjUqHpbSBXbLr2NCMFNbRPinK3E3INt1lrx0y_fS0ZLgq8jxbvtcEc2MsdY86MbiIVQc1U69_gOOnetIglMofkbXItmVauaUZ9kQ7mo4XCm6G5y3I11hzpvIpdEUqk9jrEF-xGbcVZ_Na9ulbmINfr9q-WTBcLh2pArIi-ghYafPytwB0PpXsFJAMN5hKyyp7dvHrCOVCg9ltadUxCbvCImHz0OmMw8CsWTt8zbXRvmcW4X8VVIZpxM7PmijZQtD_yB5PuHWrp8iiQrZ7KlE.ZWU0ZWIzMTktMWRhNi00Mzg0LTllMzYtNzlmMDU3MjRmYTkx";
const mapName = "map-try-2";
const region = "us-east-1";
// enum OfflineDataState { unknown, downloaded, downloading, notDownloaded }

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Map();
  }
}

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State createState() => MapState();
}

class MapState extends State<Map> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: MaplibreMap(
        styleString: styleString,
        myLocationEnabled: true,
        initialCameraPosition: const CameraPosition(target: LatLng(40.776676, -73.971321), zoom: 12.25, bearing: 28.5),
        dragEnabled: false,
        zoomGesturesEnabled: false,
        rotateGesturesEnabled: false,
        compassEnabled: false,
        cameraTargetBounds: CameraTargetBounds(LatLngBounds(northeast: const LatLng(40.800875, -73.914747), southwest: const LatLng(40.701539, -74.023967))) 
      )
    );
  }
}
