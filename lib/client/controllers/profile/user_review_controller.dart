import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../service_provider/models/reviews/reviews_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../user/user_controller.dart';

class ClientReviewController extends GetxController {
  var isLoading = false.obs;
  var review = Rxn<Reviews>();
  var rating = 0.0.obs;
  var reviewText = ''.obs;
  final reviewController = TextEditingController();

  Future<void> loadReview(String serviceProviderId, String currentUserId) async {
    isLoading.value = true;
    try {
      final serviceProviderDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(serviceProviderId)
          .get();

      if (serviceProviderDoc.exists) {
        var reviews = serviceProviderDoc.data()?['reviews'] ?? [];
        for (var rev in reviews) {
          if (rev['reviewUserId'] == currentUserId) {
            review.value = Reviews.fromMap(rev);
            rating.value = review.value!.reviewUserRating!;
            reviewText.value = review.value!.reviewUserText ?? '';
            break;
          }
        }
      }
    } catch (e) {
      CustomSnackbar.showSnackBar(
        'Error',
        'Error fetching review: $e',
        const Icon(Icons.error),
        Colors.red,
        Get.context!,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitOrUpdateReview(String serviceProviderId, String leadId) async {
    if (rating.value == 0.0 || reviewText.isEmpty) {
      CustomSnackbar.showSnackBar(
        'Error',
        'Please fill in all fields.',
        const Icon(Icons.error),
        Colors.red,
        Get.context!,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Set or update review
      final newReview = Reviews(
        reviewUserId: Get.find<UserController>().userModel.value!.uid,
        reviewUserText: reviewText.value,
        reviewUserRating: rating.value,
        serviceProviderId: serviceProviderId,
        reviewUserName: Get.find<UserController>().userModel.value!.userName,
        reviewDate: DateTime.now(),
        leadId: leadId,
        reviewId: DateTime.now().toIso8601String(),
      );

      // Update Firestore
      final serviceProviderRef = FirebaseFirestore.instance.collection('users').doc(serviceProviderId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(serviceProviderRef);
        if (!snapshot.exists) throw Exception("Service provider not found.");

        final List<dynamic> currentReviews = snapshot.data()?['reviews'] ?? [];
        final reviewIndex = currentReviews.indexWhere((rev) => rev['reviewUserId'] == newReview.reviewUserId);

        if (reviewIndex != -1) {
          currentReviews[reviewIndex] = newReview.toMap();
        } else {
          currentReviews.add(newReview.toMap());
        }

        // Calculate new average rating
        double avgRating = 0.0;
        if (currentReviews.isNotEmpty) {
          avgRating = currentReviews
              .map((r) => (r['reviewUserRating'] ?? 0).toDouble())
              .fold(0.0, (a, b) => a + b) / currentReviews.length;
        }

        // Update both reviews and companyInfo.averageRating atomically
        transaction.update(serviceProviderRef, {
          'reviews': currentReviews,
          'companyInfo.averageRating': avgRating,
        });
      });

      review.value = newReview;

      CustomSnackbar.showSnackBar(
        'Success',
        'Review submitted successfully!',
        const Icon(Icons.check_circle, color: Colors.white),
        Colors.green,
        Get.context!,
      );

    } catch (e) {
      CustomSnackbar.showSnackBar(
        'Error',
        'Failed to submit review.',
        const Icon(Icons.error),
        Colors.red,
        Get.context!,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
