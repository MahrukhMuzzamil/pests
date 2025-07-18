import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../data/keys.dart';

class GeocodingService {
  Future<List<Map<String, String>>> getCityAndCountry(String postalCode,
      {String units = 'degrees'}) async {
    final formattedPostalCode = Uri.encodeComponent(postalCode.trim());

    if (_isValidUsPostalCode(postalCode)) {
      return await _getUsCityAndCountry(formattedPostalCode);
    } else if (_isValidCanadaPostalCode(postalCode)) {
      return await _getCanadaCityAndCountry(formattedPostalCode, units: units);
    } else {
      throw Exception('Invalid postal code format');
    }
  }


  Future<List<Map<String, String>>> _getUsCityAndCountry(String postalCode) async {
    final url = Uri.parse(
      'https://api.geoapify.com/v1/geocode/search?postcode=$postalCode&country=United States&format=json&apiKey=${Keys.geoApifyKey}',
    );

    print('Fetching US data from URL: $url');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        // Filter for exact postal code matches
        final exactMatches = data['results'].where((result) {
          final Map<String, dynamic> resultMap = result as Map<String, dynamic>;
          return resultMap['postcode']?.toString() == postalCode;
        }).map<Map<String, String>>((result) {
          final Map<String, dynamic> resultMap = result as Map<String, dynamic>;
          return {
            'city': resultMap['city']?.toString() ?? '',
            'state': resultMap['state']?.toString() ?? '',
            'country': resultMap['country']?.toString() ?? '',
            'postalCode': resultMap['postcode']?.toString() ?? '',
          };
        }).toList();

        // Check if there are exact matches
        if (exactMatches.isNotEmpty) {
          return exactMatches;
        } else {
          throw Exception('No exact matches found for postal code');
        }
      } else {
        throw Exception('No results found for postal code');
      }
    } else {
      throw Exception('Failed to fetch data. Status Code: ${response.statusCode}');
    }
  }



  Future<List<Map<String, String>>> _getCanadaCityAndCountry(String postalCode,
      {String units = 'degrees'}) async {
    final url =
        'https://www.zipcodeapi.com/rest/v2/CA/${Keys.postalCodeApiKey}/info.json/$postalCode/$units';

    print('Fetching Canada data from URL: $url');
    return await _fetchData(url, isCanada: true);
  }

  Future<List<Map<String, String>>> _fetchData(String url,
      {bool isCanada = false}) async {
    try {
      final response = await http.get(Uri.parse(url));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        List<Map<String, String>> locations = [];

        if (isCanada) {
          final city = data['city'] ?? 'Not found';
          final province = data['province'] ?? 'Not found';
          final latitude = data['lat']?.toString() ?? 'Not found';
          final longitude = data['lng']?.toString() ?? 'Not found';
          final postalCode = data['postal_code'] ?? 'Not found';

          locations.add({
            'city': city,
            'state': province,
            'latitude': latitude,
            'longitude': longitude,
            'postalCode': postalCode,
          });
        } else {
          if (data.isNotEmpty) {
            for (var item in data) {
              final city = item['address']['city'] ??
                  item['address']['town'] ??
                  item['address']['village'] ??
                  'Not found';
              final country = item['address']['country'] ?? 'Not found';
              final postalCode = item['address']['postcode'] ?? 'Not found';

              locations.add({
                'city': city,
                'country': country,
                'postalCode': postalCode,
              });
            }
          } else {
            print('No data found');
            return [];
          }
        }

        return locations;
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  bool _isValidUsPostalCode(String postalCode) {
    final usPostalCodeRegEx = RegExp(r'^\d{5}(-\d{4})?$');
    return usPostalCodeRegEx.hasMatch(postalCode);
  }

  bool _isValidCanadaPostalCode(String postalCode) {
    final canadaPostalCodeRegEx = RegExp(r'^[A-Za-z]\d[A-Za-z] ?\d[A-Za-z]\d$');
    return canadaPostalCodeRegEx.hasMatch(postalCode);
  }
}
