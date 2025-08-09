import 'dart:math';
import 'package:get/get.dart';
import 'package:pests247/services/job_board_service.dart';
import 'package:pests247/shared/models/job/job_post.dart';

class JobAlertsController extends GetxController {
  var jobs = <JobPost>[].obs;
  var isLoading = false.obs;

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const double rMiles = 3958.8; // radius of earth in miles
    double toRad(double deg) => deg * pi / 180;
    final dLat = toRad(lat2 - lat1);
    final dLon = toRad(lon2 - lon1);
    final a =
        (sin(dLat / 2) * sin(dLat / 2)) + cos(toRad(lat1)) * cos(toRad(lat2)) * (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return rMiles * c;
  }

  Future<void> fetchNearbyJobs({
    required double latitude,
    required double longitude,
    double radiusMiles = 100,
  }) async {
    isLoading.value = true;
    try {
      final all = await JobBoardService.fetchJobsNearby(
        latitude: latitude,
        longitude: longitude,
        maxMiles: radiusMiles,
      );
      jobs.value = all
          .where((j) => _haversine(latitude, longitude, j.latitude, j.longitude) <= radiusMiles)
          .toList();
    } finally {
      isLoading.value = false;
    }
  }
}


