import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';

import '../../../client/widgets/custom_snackbar.dart';
import '../../../shared/models/user/user_model.dart';
import '../../models/reviews/reviews_model.dart';
import '../../screens/profile/components/reviews/components/user_review_respond_screen.dart';

class ReviewController extends GetxController {
  var isLoading = false.obs;
  var replyValue = ''.obs;

  final replyController = TextEditingController();

  void goToReplyScreen(Reviews review) {
    Get.to(() => ReplyScreen(review: review), transition: Transition.cupertino);
  }

  void setRespondValue(String replyText) {
    replyController.text = replyText;

    replyValue.value = replyText;
  }

  bool isChanged(String reviewId) {
    UserController userController = Get.find();
    UserModel? userModel = userController.userModel.value;

    final existingReview = userModel?.reviews?.firstWhere(
      (review) => review.reviewId == reviewId,
      orElse: null,
    );
    return existingReview != null &&
        replyValue.value != (existingReview.serviceProviderReply ?? '');
  }

  Future<void> postOrUpdateReply(String reviewId, String replyText,
      String userId, BuildContext context) async {
    isLoading.value = true;

    if (isChanged(reviewId)) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final reviews =
              List<Map<String, dynamic>>.from(userDoc.data()!['reviews']);

          for (var review in reviews) {
            if (review['reviewId'] == reviewId) {
              review['serviceProviderReply'] = replyText;
              break;
            }
          }

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'reviews': reviews,
          });
          isLoading.value = false;
          final UserController userController = Get.find();
          userController.fetchUser();
          setRespondValue(replyValue.value);

          CustomSnackbar.showSnackBar(
            'Success',
            'Reply updated successfully.',
            const Icon(Icons.check, color: Colors.green),
            Colors.green,
            context,
          );
        } else {
          isLoading.value = false;

          CustomSnackbar.showSnackBar(
            'Error',
            'User or reviews not found.',
            const Icon(Icons.error, color: Colors.red),
            Colors.red,
            context,
          );
        }
      } catch (error) {
        isLoading.value = false;

        CustomSnackbar.showSnackBar(
          'Error',
          'Failed to update reply. Please try again later.',
          const Icon(Icons.error, color: Colors.red),
          Colors.red,
          context,
        );
      }
    } else {
      isLoading.value = false;
      CustomSnackbar.showSnackBar(
        'Info',
        'No changes detected.',
        const Icon(Icons.info, color: Colors.blue),
        Colors.blue,
        Get.context!,
      );
    }
  }
}
