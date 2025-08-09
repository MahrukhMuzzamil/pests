import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../data/keys.dart';
import '../models/job/job_model.dart';
import 'email_service.dart';

class JobService {
  final FirebaseFirestore _firestore;
  JobService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, double>> _getCoordinatesFromPostalCode(String postalCode) async {
    String country;
    if (RegExp(r'^\d{5}(-\d{4})?$').hasMatch(postalCode)) {
      country = 'United States';
    } else if (RegExp(r'^[A-Za-z]\d[A-Za-z][ -]?\d[A-Za-z]\d$').hasMatch(postalCode)) {
      country = 'Canada';
    } else {
      throw Exception('Invalid postal code');
    }

    final url = Uri.parse(
      'https://api.geoapify.com/v1/geocode/search?postcode=$postalCode&country=$country&format=json&apiKey=${Keys.geoApifyKey}',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        final lat = (data['results'][0]['lat'] as num).toDouble();
        final lon = (data['results'][0]['lon'] as num).toDouble();
        return {'lat': lat, 'lon': lon};
      }
      throw Exception('No geocode results');
    }
    throw Exception('Failed to geocode ${response.statusCode}');
  }

  Future<JobModel> postJob({
    required String title,
    required String description,
    required String locationText,
    required String postedByUserId,
  }) async {
    await Keys.loadAllKeys();

    final postalCodeMatch = RegExp(r'(\b\d{5}(?:-\d{4})?\b|\b[A-Za-z]\d[A-Za-z][ -]?\d[A-Za-z]\d\b)')
        .firstMatch(locationText);
    if (postalCodeMatch == null) {
      throw Exception('Postal code required in location');
    }
    final postalCode = postalCodeMatch.group(0)!;

    final coords = await _getCoordinatesFromPostalCode(postalCode);

    final String jobId = const Uuid().v4();
    final job = JobModel(
      jobId: jobId,
      title: title,
      description: description,
      locationText: locationText,
      latitude: coords['lat']!,
      longitude: coords['lon']!,
      postedByUserId: postedByUserId,
      createdAt: DateTime.now(),
      status: 'open',
    );

    await _firestore.collection('jobs').doc(jobId).set(job.toMap());

    // Trigger backend email notifications
    await EmailService.sendJobAlertEmails(jobId: jobId);

    return job;
  }
}