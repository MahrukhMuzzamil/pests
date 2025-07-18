import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';
import 'package:pests247/client/widgets/custom_button.dart';
import 'package:pests247/client/widgets/custom_text_field.dart';
import '../../../../../controllers/profile/user_review_controller.dart';
import '../../../../../models/reviews/reviews_model.dart';

class ReplyScreen extends StatelessWidget {
  final Reviews review;

  const ReplyScreen({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final reviewController = Get.find<ReviewController>();
    final userController = Get.find<UserController>();
    reviewController.setRespondValue(userController.userModel.value?.reviews
            ?.firstWhere((reviewss) => reviewss.reviewId == review.reviewId,
                orElse: null)
            .serviceProviderReply ??
        '');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          review.serviceProviderReply != null
              ? 'Edit Reply'
              : 'Respond to Review',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You can publicly post a response to this review. Other visitors to your profile will be able to see this reply.',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 20),

            // Review text and rating
            Text(
              review.reviewUserText ?? 'No Review Text',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < (review.reviewUserRating.floor() ?? 0)
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.blue[700],
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Reply TextField
            buildTextField(
                onChanged: (value) {
                  reviewController.replyValue.value = value;
                },
                controller: reviewController.replyController,
                minLines: 6,
                labelText: 'Enter your reply'),
            const SizedBox(height: 50),

            // Save button
            Align(
              alignment: Alignment.center,
              child: Obx(
                () => CustomButton(
                  onPressed: reviewController.isChanged(review.reviewId!)
                      ? () {
                          final reviewController = Get.find<ReviewController>();
                          final UserController userController = Get.find();

                          reviewController.postOrUpdateReply(
                              review.reviewId!,
                              reviewController.replyValue.value,
                              userController.userModel.value!.uid,
                              context);
                        }
                      : () {},
                  text: 'Respond',
                  isLoading: reviewController.isLoading.value,
                  tag: 'review',
                  height: 45,
                  textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                  backgroundColor: reviewController.isChanged(review.reviewId!)
                      ? Colors.blue
                      : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
