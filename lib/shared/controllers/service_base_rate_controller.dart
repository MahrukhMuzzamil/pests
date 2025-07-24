import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_base_rate.dart';

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
}