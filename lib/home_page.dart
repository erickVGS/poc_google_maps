import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:web_view_maps/location_services.dart';

class MyMapView extends StatefulWidget {
  const MyMapView({Key? key}) : super(key: key);

  @override
  _MyMapViewState createState() => _MyMapViewState();
}

class _MyMapViewState extends State<MyMapView> {
  Completer<GoogleMapController> _controller = Completer();

  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final Set<Marker> markers = Set<Marker>();
  final Set<Polygon> polygons = Set<Polygon>();
  final Set<Polyline> polyline = Set<Polyline>();
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
    _setMarker(const LatLng(
      -16.028340,
      -47.987706,
    ));
  }

  void _setMarker(LatLng point) {
    setState(() {
      markers.add(
        Marker(markerId: MarkerId('marker'), position: point),
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
        title: Text('POC_GoogleMaps'),
      ),
      body: Column(
        children: [
          Row(children: [
            Expanded(
              child: Column(
                children: [
                  TextFormField(
                    controller: _originController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(hintText: 'Origem'),
                    onChanged: (value) {
                      print(value);
                    },
                  ),
                  TextFormField(
                    controller: _destinationController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(hintText: 'Destino'),
                    onChanged: (value) {
                      print(value);
                    },
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                LocationService().getCoordinates(_originController.text);
                // var directions = await LocationService().getDirections(
                //     _originController.text, _destinationController.text);
                // // var place =
                // //     await LocationService().getPlace(_searchController.text);
                // // _goToPlace(place);
                // _goToPlace(
                //   directions['start_location']['lat'],
                //   directions['start_location']['lng'],
                //   directions['bounds_ne'],
                //   directions['bounds_sw'],
                // );

                // setPolyline(directions['polyline_decoded']);
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

  Future<void> _goToPlace(
    double lat,
    double lng,
    Map<String, dynamic> boundsNe,
    Map<String, dynamic> boundsSw,
  ) async {
    // final double lat = place['geometry']['location']['lat'];
    // final double lng = place['geometry']['location']['lng'];

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(lat, lng),
        zoom: 12,
      ),
    ));

    controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
          northeast: LatLng(boundsNe['lat'], boundsNe['lng']),
        ),
        25));
    _setMarker(LatLng(lat, lng));
  }

  // Future<void> _goToTheLake() async {
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(
  //     CameraUpdate.newCameraPosition(_secondPlace),
  //   );
  // }
}
