import 'dart:convert';
import 'dart:convert' as convert;

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;

class LocationService {
  String key = 'AIzaSyCXHcUfFP3mWnb0AU0Cm7BLCk90_qy3LGQ';
  final apiKey = 'WVpJHfR2zeALMGzHh4TcKA4HnfkH';

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

  Future<Map<String, dynamic>> getDirections(Map location) async {
    const String url =
        'https://api.maplink.global/trip/v2/calculations?pointsMode=polyline';

    try {
      var response = await http.post(
        Uri.parse(url),
        body: convert.jsonEncode({
          "calculationMode": "THE_FASTEST",
          "points": [
            {
              "siteId": "Poin",
              "latitude": location['origin']['lat'],
              "longitude": location['origin']['lng'],
            },
            {
              "siteId": "Point Betim",
              "latitude": location['destination']['lat'],
              "longitude": location['destination']['lng'],
            },
          ]
        }),
        headers: {
          "Authorization": 'Bearer $apiKey',
          "Content-Type": "application/json",
        },
      );
      print(response);
      var json = convert.jsonDecode(response.body);
      print(json);
      var results = {
        'bounds_ne': {
          'lat': location['origin']['lat'],
          'lng': location['origin']['lng'],
        },
        'bounds_sw': {
          'lat': location['destination']['lat'],
          'lng': location['destination']['lng'],
        },
        'start_location': {
          'lat': location['origin']['lat'],
          'lng': location['origin']['lng'],
        },
        'end_location': {
          'lat': location['destination']['lat'],
          'lng': location['destination']['lng'],
        },
        'polyline': json['legs'][0]['points'],
        'polyline_decoded':
            PolylinePoints().decodePolyline(json['legs'][0]['points']),
      };
      print(results);
      return results;
    } catch (e) {
      print(e);
      return {};
    }
  }

  Future<Map<String, dynamic>?> getCoordinates(String address) async {
    try {
      final url = Uri.parse(
          'https://api.maplink.global/geocode/v1/suggestions?q=$address&type=ZIPCODE');

      final response = await http.get(url, headers: {
        "Authorization": 'Bearer $apiKey',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final location = data['results'][0]['address']['mainLocation'];
        return {
          'latitude': location['lat'],
          'longitude': location['lon'],
        };
      } else {
        return null;
      }
    } catch (e) {
      print(e);
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
