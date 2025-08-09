import 'dart:math';


double haversine(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371; // Earth radius in km
  double dLat = (lat2 - lat1) * pi / 180;
  double dLon = (lon2 - lon1) * pi / 180;
  double a = sin(dLat/2) * sin(dLat/2) +
      cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
      sin(dLon/2) * sin(dLon/2);
  double c = 2 * atan2(sqrt(a), sqrt(1-a));
  return R * c;
}

double haversineMiles(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadiusMiles = 3958.8;
  double toRadians(double degrees) => degrees * pi / 180;
  final double dLat = toRadians(lat2 - lat1);
  final double dLon = toRadians(lon2 - lon1);
  final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(toRadians(lat1)) * cos(toRadians(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadiusMiles * c;
}

bool isWithinMilesRadius({
  required double sourceLat,
  required double sourceLon,
  required double targetLat,
  required double targetLon,
  required double maxMiles,
}) {
  return haversineMiles(sourceLat, sourceLon, targetLat, targetLon) <= maxMiles;
}