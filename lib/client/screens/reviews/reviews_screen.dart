import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/widgets/custom_button.dart';
import 'package:pests247/client/widgets/custom_text_field.dart';
import 'package:pests247/shared/models/lead_model/lead_model.dart';
import '../../controllers/profile/user_review_controller.dart';

class ClientReviewScreen extends StatelessWidget {
  final String serviceProviderId;
  final String leadId;
  final LeadModel lead;

  const ClientReviewScreen(
      {super.key, required this.leadId, required this.serviceProviderId, required this.lead});

  @override
  Widget build(BuildContext context) {
    final ClientReviewController reviewController =
    Get.put(ClientReviewController());
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Submit Your Review',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Descriptive Text
              const Text(
                'Let others know about your experience. Your feedback is important!',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Rating Stars
              Obx(() {
                return Row(
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < reviewController.rating.value
                            ? Icons.star
                            : Icons.star_border,
                        size: 38,
                        color: Colors.blue,
                      ),
                      onPressed: () {
                        reviewController.rating.value = index + 1.0;
                      },
                    );
                  }),
                );
              }),

              const SizedBox(height: 20),

              // Review Text Field
              buildTextField(
                controller: reviewController.reviewController,
                minLines: 6,
                onChanged: (text) {
                  reviewController.reviewText.value = text;
                },
                labelText: 'Write your review...',
              ),

              const SizedBox(height: 20),

              // Spacer to push button to bottom
              const Spacer(),

              // Submit Button
              Obx(() {
                return CustomButton(
                  height: 45,
                  textStyle:
                  const TextStyle(fontSize: 15, color: Colors.white),
                  backgroundColor: Colors.blue,
                  onPressed: reviewController.isLoading.value
                      ? () => {}
                      : () async {
                    await reviewController.submitOrUpdateReview(
                      serviceProviderId,
                      leadId,
                    );
                  },
                  text: 'Submit Review',
                  isLoading: reviewController.isLoading.value,
                  tag: 'reviewButton',
                );
              }),
              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }
}
