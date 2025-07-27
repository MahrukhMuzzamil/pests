import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_base_rate.dart';
import 'package:pests247/shared/utils/distance_utils.dart';
import 'package:pests247/shared/utils/distance_utils.dart';
class ServiceBaseRateController {
  static Future<double?> getMinPriceForCategory(String categoryName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('serviceBaseRates')
        .where('categoryName', isEqualTo: categoryName)
        .limit(1)
        .get();
    print('Docs for $categoryName: ${snapshot.docs.length}');
    if (snapshot.docs.isNotEmpty) {
      return ServiceBaseRate.fromMap(snapshot.docs.first.data()).minPrice;
    }
    return null;
  }

  // Example: jobLat, jobLng, providerLat, providerLng
  void sendNotificationIfWithinDistance(double jobLat, double jobLng, double providerLat, double providerLng) {
    double distance = haversine(jobLat, jobLng, providerLat, providerLng);
  if (distance <= 100) {
      // Send notification/email to provider
    }
  }
}