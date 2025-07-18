import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/credits/credit_model.dart';

class CreditsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchCreditPackages();
  }

  var creditPackages = <CreditModel>[].obs;

  // Loading indicator
  var isLoading = false.obs;

  // Selected credits for the slider
  var selectedCredits = 5.obs;

  Future<void> fetchCreditPackages() async {
    try {
      isLoading(true);
      final querySnapshot = await _firestore.collection('creditsPackages').get();
      creditPackages.value = querySnapshot.docs
          .map((doc) => CreditModel.fromMap(doc.data(), doc.id))
          .toList();
      creditPackages.sort((a, b) => a.credits.compareTo(b.credits));

    } catch (e) {
      print('Error fetching credit packages: $e');
    } finally {
      isLoading(false);
    }
  }
}
