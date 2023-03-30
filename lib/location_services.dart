import 'dart:convert';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class LocationService {
  String key = 'AIzaSyCXHcUfFP3mWnb0AU0Cm7BLCk90_qy3LGQ';
  final apiKey = 'kyklDzA1f9oGHCN3cv2HUHZzqAOI';

  Future<String> getPlaceId(String input) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);

    var placeId = json['candidates'][0]['place_id'];

    print(placeId);

    return placeId;
  }

  Future<Map<String, dynamic>> getPlace(String input) async {
    final placeId = await getPlaceId(input);
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);

    var results = json['result'];

    print(results);

    return results;
  }

  Future<Map<String, dynamic>> getDirections(
      String origin, String destination) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key';

    try {
      var response = await http.get(Uri.parse(url));
      var json = convert.jsonDecode(response.body);
      print(json);
      var results = {
        'bounds_ne': json['routes'][0]['bounds']['northeast'],
        'bounds_sw': json['routes'][0]['bounds']['southwest'],
        'start_location': json['routes'][0]['legs'][0]['start_location'],
        'end_location': json['routes'][0]['legs'][0]['end_location'],
        'polyline': json['routes'][0]['overview_polyline']['points'],
        'polyline_decoded': PolylinePoints()
            .decodePolyline(json['routes'][0]['overview_polyline']['points']),
      };
      print(results);
      return results;
    } catch (e) {
      print(e);
      return {};
    }
  }

  Future<Map<String, dynamic>?> getCoordinates(String address) async {
    final url = Uri.parse(
        'https://api.maplink.global/geocode/v1/geocode/json?address=$address');

    final response = await http.post(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['results'][0]['location'];
      return {
        'latitude': location['lat'],
        'longitude': location['lng'],
      };
    } else {
      return null;
    }
  }

  Future<String?> getAddressByCoordinates(double lat, double lng) async {
    String url =
        'https://api.maplink.global/geocode/v1/reverse/json?lat=$lat&lon=$lng&key=$apiKey';

    var response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);

      if (jsonResponse['result'] != null && jsonResponse['result'].length > 0) {
        var address = jsonResponse['result'][0]['address'];
        return "${address['street']}, ${address['number']} - ${address['neighborhood']}, ${address['city']['name']} - ${address['state']['name']}, ${address['country']['name']}";
      }
    }

    return null;
  }

  Future<List<String>?> searchSuggestionsAddress(double lat, double lng) async {
    String url = 'https://api.maplink.global/geocode/v1/suggestions';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);

      if (jsonResponse['result'] != null && jsonResponse['result'].length > 0) {
        List<String> sugestoes = [];

        for (var suggestion in jsonResponse['result']) {
          sugestoes.add(
              "${suggestion['address']['street']}, ${suggestion['address']['number']} - ${suggestion['address']['neighborhood']}, ${suggestion['address']['city']['name']} - ${suggestion['address']['state']['name']}, ${suggestion['address']['country']['name']}");
        }

        return sugestoes;
      }
    }

    return null;
  }

  Future<List<List<double>>?> calculaMatrizDistancia(double lat1, double lng1,
      double lat2, double lng2, double lat3, double lng3) async {
    String url = 'https://api.maplink.global/matrix/v1/solutions/{{matrixId}}';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);

      if (jsonResponse['result'] != null && jsonResponse['result'].length > 0) {
        var distanceMatrix = jsonResponse['result'][0]['distanceMatrix'];
        List<List<double>> matrizDistancia = [];

        for (var row in distanceMatrix) {
          List<double> linhaDistancia = [];

          for (var distance in row) {
            linhaDistancia.add(distance.toDouble());
          }

          matrizDistancia.add(linhaDistancia);
        }

        return matrizDistancia;
      }
    }

    return null;
  }
}
