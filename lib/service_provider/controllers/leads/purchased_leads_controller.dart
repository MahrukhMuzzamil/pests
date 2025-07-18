import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../client/controllers/user/user_controller.dart';
import '../../../client/widgets/custom_snackbar.dart';
import '../../../shared/models/lead_model/lead_model.dart';
import '../../../shared/models/user/user_model.dart';
import '../../models/activity_logs/activity_logs_model.dart';
import '../../models/buyer/buyer_model.dart';
import '../../models/quote/quote_model.dart';

class PurchasedLeadsController extends GetxController {
  var purchasedLeads = <LeadModel>[].obs;
  var filteredLeads = <LeadModel>[].obs;
  var isLoading = true.obs;
  var isSortedByNewest = true.obs;
  var selectedStatus = 'all'.obs;
  var userDetailsMap = <String, UserModel>{}.obs;
  var currentStatus = ''.obs;


  Future<void> sendQuote(LeadModel lead, double price, String feeType, String additionalDetails) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      Buyer currentBuyer = lead.buyers.firstWhere((buyer) => buyer.userId == currentUserId);

      String quoteId = DateTime.now().millisecondsSinceEpoch.toString();

      // Create a new quote
      Quote newQuote = Quote(
        id: quoteId,
        price: price,
        additionalDetails: additionalDetails,
        feeType: feeType,
        timestamp: DateTime.now(),
      );

      currentBuyer.quotes.add(newQuote.toMap());

      ActivityLog activityLog = ActivityLog(
        title: 'Quote Sent',
        description: 'Quote of C\$${price} sent with details: "$additionalDetails".',
      );
      currentBuyer.activityLogs.add(activityLog);

      await FirebaseFirestore.instance.collection('leads').doc(lead.leadId).update({
        'buyers': lead.buyers.map((buyer) => buyer.toMap()).toList(),
      });

      CustomSnackbar.showSnackBar(
        'Success',
        'Quote sent successfully.',
        const Icon(Icons.check_circle_outline, color: Colors.white70),
        Colors.green,
        Get.context!,
      );
    } catch (e) {
      CustomSnackbar.showSnackBar(
        'Error',
        'Failed to send quote. Please try again.',
        const Icon(Icons.error, color: Colors.red),
        Colors.red,
        Get.context!,
      );
    }
  }



  Future<void> updateLeadStatus(LeadModel lead, String newStatus) async {
    try {
      String currentUserId = Get.find<UserController>().userModel.value!.uid;

      Buyer currentBuyer = lead.buyers.firstWhere((buyer) => buyer.userId == currentUserId);

      String oldStatus = currentBuyer.status;
      ActivityLog activityLog = ActivityLog(
        title: 'Status Updated',
        description: 'Status changed from $oldStatus to $newStatus',
      );

      currentBuyer.status = newStatus;
      currentBuyer.activityLogs.add(activityLog);

      await FirebaseFirestore.instance.collection('leads').doc(lead.leadId).update({
        'buyers': lead.buyers.map((buyer) => buyer.toMap()).toList(),
        'status': newStatus,
      });

      currentStatus.value = newStatus;

      filterLeadsByStatus(selectedStatus.value);

      CustomSnackbar.showSnackBar(
        'Success',
        'Lead status updated successfully',
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




  Future<void> fetchUserDetailById(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (snapshot.exists) {
        userDetailsMap[userId] =
            UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }


  void toggleSorting() {
    isSortedByNewest.value = !isSortedByNewest.value;
    sortFilteredLeads();
  }

  void sortFilteredLeads() {
    if (isSortedByNewest.value) {
      filteredLeads.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    } else {
      filteredLeads.sort((a, b) => a.submittedAt.compareTo(b.submittedAt));
    }
  }

  void filterLeadsByStatus(String status) {
    selectedStatus.value = status;
    if (status == 'all') {
      filteredLeads.value = List.from(purchasedLeads);
    } else {
      filteredLeads.value = purchasedLeads.where((lead) {
        return lead.buyers.any((buyer) => buyer.status == status);
      }).toList();
    }
    sortFilteredLeads();
  }

  Future<void> fetchPurchasedLeads() async {
    isLoading.value = true;
    try {
      final UserController userController = Get.find();

      while (userController.userModel.value == null || userController.isLoading.value) {
        await Future.delayed(const Duration(milliseconds: 2000));
      }

      UserModel? user = userController.userModel.value;
      if (user == null) {
        print("User model is null.");
        return;
      }

      final snapshot = await FirebaseFirestore.instance.collection('leads').get();

      if (snapshot.docs.isEmpty) {
        print("No leads found in Firestore.");
        return;
      }

      purchasedLeads.value = snapshot.docs.map((doc) {
        return LeadModel.fromMap(doc.data());
      }).toList();

      purchasedLeads.value = purchasedLeads.where((lead) {
        return lead.buyers.any((buyer) => buyer.userId == user.uid);
      }).toList();

      filteredLeads.value = List.from(purchasedLeads);
      sortFilteredLeads();
    } catch (e) {
      print("Error fetching purchased leads: $e");
    } finally {
      isLoading.value = false;
    }
  }



  @override
  void onInit() {
    super.onInit();
    fetchPurchasedLeads();
  }
}
