import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/models/lead_model/lead_model.dart';
import '../../../shared/models/job/job_post.dart';
import '../../../services/job_board_service.dart';
import '../../widgets/custom_snackbar.dart';
import 'package:uuid/uuid.dart';

import '../user/user_controller.dart';
import 'geo_coding_service.dart';

class LeadsFormController extends GetxController {
  var currentPage = 0.obs;
  var selectedPropertyType = ''.obs;
  var selectedPests = <String>[].obs;
  var sightingsFrequency = ''.obs;
  var selectedServices = <String>[].obs;
  var hiringDecision = ''.obs;
  var additionalDetails = ''.obs;
  var email = ''.obs;
  var password = ''.obs;
  var name = ''.obs;
  var userId = ''.obs;

  var isLoading = false.obs;
  var isSearching = false.obs;
  var suggestions = <Map<String, String>>[].obs;
  var errorMessage = ''.obs;
  var location = ''.obs;

  void clearSuggestions() {
    suggestions.clear();
    errorMessage.value = '';
  }

  void updateLocation(String selectedLocation) {
    location.value = selectedLocation;
  }

  void updateError(String error) {
    errorMessage.value = error;
  }

  final Uuid uuid = const Uuid();

  //all controllers
  var emailController = TextEditingController();
  var postalCodeController = TextEditingController();
  var passwordController = TextEditingController();
  var additionalDetailsController = TextEditingController();

  GeocodingService geocodingService = GeocodingService();
  FocusNode focusNode = FocusNode();

  bool get isPropertyTypeSelected => selectedPropertyType.value.isNotEmpty;

  bool get arePestsSelected => selectedPests.isNotEmpty;

  bool get isFrequencySelected => sightingsFrequency.value.isNotEmpty;

  bool get areServicesSelected => selectedServices.isNotEmpty;

  bool get isHiringDecisionSelected => hiringDecision.value.isNotEmpty;

  bool get isEmailValid => email.value.isEmail;

  void nextPage() {
    currentPage.value++;
  }

  void clearAll() {
    selectedPropertyType.value = '';
    selectedPests.clear();
    sightingsFrequency.value = '';
    selectedServices.clear();
    hiringDecision.value = '';
    location.value = '';
    email.value = '';
    password.value = '';
    name.value = '';
    additionalDetails.value = '';
    userId.value = '';
    isLoading.value = false;
    emailController.clear();
    passwordController.clear();
  }

  void verifyAndSubmit(
      BuildContext context, UserController userController) async {
    isLoading.value = true;
    bool isVerified =
        await verifyPassword(emailController.text, passwordController.text);
    if (isVerified) {
      name.value = userController.userModel.value!.userName;
      userId.value = userController.userModel.value!.uid;
      await submitLead();
      currentPage.value = 9;
    } else {
      CustomSnackbar.showSnackBar(
        'Error',
        'Invalid credentials. Please try again.',
        const Icon(Icons.error, color: Colors.red),
        Colors.red,
        context,
      );
    }
    isLoading.value = false;
  }

  Future<int> fetchCreditsForDecision(String hiringDecision) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('leadsPrices')
          .doc('leadsCredits')
          .get();

      final data = doc.data();
      if (data == null) {
        print("No data found in leadsCredits document.");
        return 5;
      }

      for (int i = 1; i <= 5; i++) {
        String decisionKey = 'decision$i';
        String creditKey = 'credit$i';

        String? decision = data[decisionKey] as String?;
        num? credit = data[creditKey] as num?;

        print("Checking: $decisionKey = $decision, $creditKey = $credit");

        if (decision == hiringDecision) {
          print("Found matching decision: $hiringDecision with credit: $credit");
          return (credit ?? 5).toInt();
        }
      }

      print("No matching decision found for $hiringDecision.");
      return 5;
    } catch (e) {
      print("Error fetching credits: $e");
      return 5;
    }
  }





  Future<void> submitLead() async {
    try {
      print(hiringDecision.value);
      int decisionCredits = await fetchCreditsForDecision(hiringDecision.value);

      String uniqueLeadId = uuid.v4();

      final lead = LeadModel(
        credits: decisionCredits,
        propertyType: selectedPropertyType.value,
        pests: selectedPests.toList(),
        sightingsFrequency: sightingsFrequency.value,
        services: selectedServices.toList(),
        hiringDecision: hiringDecision.value,
        location: location.value,
        email: emailController.text,
        name: name.value,
        userId: userId.value,
        submittedAt: DateTime.now(),
        leadId: uniqueLeadId,
        buyers: [],
        status: 'pending',
        additionalDetails: additionalDetails.value,
      );

      await FirebaseFirestore.instance
          .collection('leads')
          .doc(uniqueLeadId)
          .set(lead.toMap());

      // Also create a lightweight job post for providers (Bark-like alert)
      try {
        final postal = _extractPostalCode(location.value);
        List<Map<String, String>> locs = await geocodingService.getCityAndCountry(postal);
        final loc = locs.isNotEmpty ? locs.first : {};
        final job = JobPost(
          id: uniqueLeadId,
          createdBy: userId.value,
          title: selectedServices.isNotEmpty ? selectedServices.first : 'Pest Control Job',
          description: additionalDetails.value,
          postalCode: postal,
          city: loc['city'],
          state: loc['state'],
          latitude: double.tryParse(loc['latitude'] ?? '') ?? 0.0,
          longitude: double.tryParse(loc['longitude'] ?? '') ?? 0.0,
          services: selectedServices.toList(),
          pests: selectedPests.toList(),
          createdAt: DateTime.now(),
        );
        await JobBoardService.createJob(job);
      } catch (_) {
        // ignore job creation errors so lead flow isn't blocked
      }
    } catch (e) {
      CustomSnackbar.showSnackBar(
        'Error',
        'Failed to submit lead. Please try again.',
        const Icon(Icons.error, color: Colors.red),
        Colors.red,
        Get.context!,
      );
      print(e.toString());
    }
  }

  String _extractPostalCode(String location) {
    // Expecting formats like "12345, City, State" or "A1A 1A1, City, Province"
    return location.split(',').first.trim();
  }


  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
    }
  }

  Future<bool> verifyPassword(String email, String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        CustomSnackbar.showSnackBar(
          'Error',
          'No user is logged in.',
          const Icon(Icons.error, color: Colors.red),
          Colors.red,
          Get.context!,
        );
        return false;
      }

      AuthCredential credential =
          EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      CustomSnackbar.showSnackBar(
        'Error',
        'Password verification failed. Please try again.',
        const Icon(Icons.error, color: Colors.red),
        Colors.red,
        Get.context!,
      );
      print(e.toString());
      return false;
    }
  }
}
