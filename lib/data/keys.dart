import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class Keys {
  static String geoApifyKey = "";
  static String postalCodeApiKey = "";
  static String stripeSecretKey = "";
  static String stripePublishKey = "";
  static String fcmProjectId = "";
  static Map<String, dynamic> fcmServiceAccount = <String, dynamic>{};

  /// Load all keys from Firebase
  static Future<void> loadAllKeys() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('config')
          .doc('apiKeys')
          .get();

      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data();
        if (data != null) {
          geoApifyKey = data['geoApifyKey'] ?? "";
          postalCodeApiKey = data['postalCodeApiKey'] ?? "";
          stripePublishKey = data['stripePublishKey'] ?? "";
          stripeSecretKey = data['stripeSecretKey'] ?? "";
          // FCM keys
          fcmProjectId = data['fcmProjectId'] ?? "";
          final dynamic sa = data['fcmServiceAccount'];
          if (sa is Map<String, dynamic>) {
            // Normalize private key newlines if stored with escaped \n
            final Map<String, dynamic> normalized = Map<String, dynamic>.from(sa);
            final dynamic pk = normalized['private_key'];
            if (pk is String && pk.contains('\\n')) {
              normalized['private_key'] = pk.replaceAll('\\n', '\n');
            }
            fcmServiceAccount = normalized;
          } else {
            fcmServiceAccount = <String, dynamic>{};
          }
          Stripe.publishableKey = stripePublishKey;
          print("Keys loaded successfully:");
        } else {
          throw Exception("No data found in the API keys document.");
        }
      } else {
        throw Exception("API keys document does not exist.");
      }
    } catch (e) {
      print("Error loading API keys: $e");
    }
  }

  static Future<double> fetchCustomOfferCommission() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('config')
        .doc('commission')
        .get();
    if (snapshot.exists) {
      final data = snapshot.data();
      return (data?['customOfferCommissionPercent'] as num?)?.toDouble() ?? 10.0;
    }
    return 20.0; // default
  }
}
