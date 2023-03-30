import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web_view_maps/location_services.dart';

class MyMapView extends StatefulWidget {
  const MyMapView({Key? key}) : super(key: key);

  @override
  _MyMapViewState createState() => _MyMapViewState();
}

class _MyMapViewState extends State<MyMapView> {
  final Completer<GoogleMapController> _controller = Completer();

  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final Set<Marker> markers = <Marker>{};
  final Set<Polygon> polygons = <Polygon>{};
  final Set<Polyline> polyline = <Polyline>{};
  List<LatLng> polygonsLatLngs = <LatLng>[];

  int polygonIdCounter = 1;
  int polylineIdCounter = 1;

  static const CameraPosition _firstPlace = CameraPosition(
      target: LatLng(
        -16.028340,
        -47.987706,
      ),
      zoom: 14.4746);
  static const CameraPosition _secondPlace = CameraPosition(
    target: LatLng(
      -16.073257,
      -47.982848,
    ),
    zoom: 19.151926040649414,
  );

  @override
  void initState() {
    super.initState();
    _setMarker([
      const LatLng(
        -16.028340,
        -47.987706,
      )
    ]);
  }

  void _setMarker(List<LatLng> points) {
    setState(() {
      markers.addAll(
        [
          for (int i = 0; i < points.length; i++)
            Marker(markerId: MarkerId('marker$i'), position: points[i]),
        ],
      );
    });
  }

  void setPolygon() {
    final String polygonIdVal = 'polygon_$polygonIdCounter';
    polygonIdCounter++;

    polygons.add(
      Polygon(
        polygonId: PolygonId(polygonIdVal),
        points: polygonsLatLngs,
        strokeWidth: 2,
        fillColor: Colors.transparent,
      ),
    );
  }

  void setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$polylineIdCounter';
    polylineIdCounter++;

    polyline.add(
      Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 2,
        color: Colors.blue,
        points: points
            .map(
              (point) => LatLng(point.latitude, point.longitude),
            )
            .toList(),
      ),
    );
  }

  // static const Marker _markerFirstPlace = Marker(
  //   markerId: MarkerId('_firstPlace'),
  //   infoWindow: InfoWindow(title: 'First Place'),
  //   icon: BitmapDescriptor.defaultMarker,
  //   position: LatLng(
  //     -16.028340,
  //     -47.987706,
  //   ),
  // );
  // static final Marker _markerSecondPlace = Marker(
  //   markerId: const MarkerId('_secondPlace'),
  //   infoWindow: const InfoWindow(title: 'Second Place'),
  //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //   position: const LatLng(
  //     -16.073257,
  //     -47.982848,
  //   ),
  // );

  // static const Polyline _polyline = Polyline(
  //   polylineId: PolylineId('_polyline'),
  //   points: [
  //     LatLng(-16.028340, -47.987706),
  //     LatLng(-16.073257, -47.982848),
  //   ],
  //   width: 5,
  // );
  // static const Polygon _polygon = Polygon(
  //     polygonId: PolygonId('_polygon'),
  //     points: [
  //       LatLng(-16.028340, -47.987706),
  //       LatLng(-16.073257, -47.982848),
  //       LatLng(-16.085, -47.982),
  //       LatLng(-16.079, -47.982),
  //     ],
  //     strokeWidth: 5,
  //     fillColor: Colors.transparent);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POC_GoogleMaps'),
      ),
      body: Column(
        children: [
          Row(children: [
            Expanded(
              child: Column(
                children: [
                  TextFormField(
                    controller: _destinationController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(hintText: 'Destino'),
                    onChanged: (value) {
                      print(value);
                    },
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                var result = await LocationService()
                    .getCoordinates(_destinationController.text);

                print(result);

                var directions = await LocationService().getDirections({
                  'origin': {
                    'lat': -15.8311007,
                    'lng': -48.0582439,
                  },
                  'destination': {
                    'lat': result?['latitude'] ?? 0.0,
                    'lng': result?['longitude'] ?? 0.0,
                  },
                });
                // var directions = await LocationService().getDirections(
                //     _originController.text, _destinationController.text);
                // var place =
                //     await LocationService().getPlace(_searchController.text);
                // _goToPlace(place);
                _goToPlace(
                  originLat: directions['start_location']['lat'],
                  originLng: directions['start_location']['lng'],
                  destLat: directions['end_location']['lat'],
                  destLng: directions['end_location']['lng'],
                  boundsNe: directions['bounds_ne'],
                  boundsSw: directions['bounds_sw'],
                );

                setPolyline(directions['polyline_decoded']);
              },
              icon: const Icon(Icons.search),
            ),
          ]),
          // Row(
          //   children: [
          //     Expanded(
          //       child: TextFormField(
          //         controller: _searchController,
          //         textCapitalization: TextCapitalization.words,
          //         decoration: InputDecoration(hintText: 'Pesquise aqui'),
          //         onChanged: (value) {
          //           print(value);
          //         },
          //       ),
          //     ),
          //     IconButton(
          //       onPressed: () async {
          //         var place =
          //             await LocationService().getPlace(_searchController.text);
          //         _goToPlace(place);
          //       },
          //       icon: const Icon(Icons.search),
          //     ),
          //   ],
          // ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              markers: markers,
              polygons: polygons,
              polylines: polyline,
              initialCameraPosition: _firstPlace,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: (point) {
                setState(() {
                  polygonsLatLngs.add(point);
                  setPolygon();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToPlace({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required Map<String, dynamic> boundsNe,
    required Map<String, dynamic> boundsSw,
  }) async {
    // final double lat = place['geometry']['location']['lat'];
    // final double lng = place['geometry']['location']['lng'];

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(originLat, originLng),
        zoom: 12,
      ),
    ));

    // controller.animateCamera(CameraUpdate.newLatLngBounds(
    //     LatLngBounds(
    //       southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
    //       northeast: LatLng(boundsNe['lat'], boundsNe['lng']),
    //     ),
    //     25));
    _setMarker([
      LatLng(originLat, originLng),
      LatLng(destLat, destLng),
    ]);
  }

  // Future<void> _goToTheLake() async {
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(
  //     CameraUpdate.newCameraPosition(_secondPlace),
  //   );
  // }
}
