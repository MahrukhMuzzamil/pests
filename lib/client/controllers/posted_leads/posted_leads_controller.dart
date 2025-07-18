import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../service_provider/models/activity_logs/activity_logs_model.dart';
import '../../../service_provider/models/buyer/buyer_model.dart';
import '../../../service_provider/models/reviews/reviews_model.dart';
import '../../../shared/models/lead_model/lead_model.dart';
import '../../../shared/models/user/user_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../user/user_controller.dart';

class PostedLeadsController extends GetxController {
  var isLoading = false.obs;
  var postedLeads = <LeadModel>[].obs;
  var buyerUserModels = <String, Rxn<UserModel>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPostedLeads();
  }

  Future<void> fetchBuyerUserModel(String userId) async {
    try {
      print('Fetching data for userId: $userId');

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      var userData = userDoc.data() as Map<String, dynamic>;
      buyerUserModels[userId] = Rxn<UserModel>(UserModel.fromJson(userData));
      print('Fetched buyer data: ${buyerUserModels[userId]!.value!.userName}');
    } catch (e) {
      print('Error fetching buyer data for $userId: $e');
    }
  }


  Future<void> updateLeadHiredPerson(LeadModel lead, String newStatus, String serviceProviderUserId, String serviceProviderName) async {
    try {
      Buyer currentBuyer = lead.buyers.firstWhere((buyer) => buyer.userId == serviceProviderUserId);
      final UserController userController = Get.find();
      String oldStatus = currentBuyer.status;

      ActivityLog statusActivityLog = ActivityLog(
        title: 'Status Updated',
        description: 'Status changed from $oldStatus to $newStatus',
      );

      ActivityLog hiredActivityLog = ActivityLog(
        title: 'Service Provider Hired',
        description: '${userController.userModel.value!.userName} hired $serviceProviderName for pest control services.',
      );

      currentBuyer.status = newStatus;
      currentBuyer.activityLogs.add(statusActivityLog);
      currentBuyer.activityLogs.add(hiredActivityLog);

      await FirebaseFirestore.instance.collection('leads').doc(lead.leadId).update({
        'buyers': lead.buyers.map((buyer) => buyer.toMap()).toList(),
        'status': newStatus,
      });

      fetchPostedLeads();

      CustomSnackbar.showSnackBar(
        'Success',
        'Request sent successfully. Status updated to Hired.',
        const Icon(Icons.check_circle_outline, color: Colors.white70),
        Colors.green,
        Get.context!,
      );
    } catch (e) {
      CustomSnackbar.showSnackBar(
        'Error',
        'Failed to update lead status. Please try again.',
        const Icon(Icons.error, color: Colors.red),
        Colors.red,
        Get.context!,
      );
    }
  }

  double calculateAverageRating(List<Reviews> reviews) {
    if (reviews.isEmpty) return 0.0;
    double totalRating = reviews.fold(0.0, (double sum, review) => sum + (review.reviewUserRating ?? 0.0));
    return totalRating / reviews.length;
  }

  Future<void> fetchPostedLeads() async {
    isLoading.value = true;
    try {
      final userId = Get.find<UserController>().userModel.value!.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('leads')
          .where('userId', isEqualTo: userId)
          .get();

      postedLeads.value = snapshot.docs.map((doc) => LeadModel.fromMap(doc.data())).toList();
    } catch (e) {
      print("Error fetching posted leads: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
