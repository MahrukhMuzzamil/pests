import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pests247/client/controllers/profile/user_review_controller.dart';
import 'package:pests247/client/screens/reviews/components/user_review_respond_screen.dart';

import '../../../../service_provider/controllers/profile/user_review_controller.dart';
import '../../../../service_provider/models/reviews/reviews_model.dart';

class ClientReviewCard extends StatelessWidget {
  const ClientReviewCard({
    super.key,
    required this.review,
    required this.rating,
  });

  final Reviews review;
  final int rating;

  @override
  Widget build(BuildContext context) {
    final reviewController = Get.put(ClientReviewController());

    // Date format function
    String formatDate(DateTime date) {
      return DateFormat('dd MMM, yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Card(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Reviewer info
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    child: Icon(
                      Icons.person,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    review.reviewUserName ?? 'Anonymous',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    formatDate(review.reviewDate ?? DateTime.now()),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Rating stars
              Row(
                children: List.generate(
                  5,
                      (starIndex) =>
                      Icon(
                        starIndex < rating ? Icons.star : Icons.star_border,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                ),
              ),
              const SizedBox(height: 10),

              // Review text
              Align(
                alignment: AlignmentDirectional.topStart,
                child: Text(
                  review.reviewUserText ?? 'No Review Text',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),

              // Provider reply display
              if (review.serviceProviderReply != null &&
                  review.serviceProviderReply!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(
                    width: Get.width,
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.serviceProviderReply ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          formatDate(review.reviewDate ?? DateTime.now()),
                          style:
                          const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 10),

              Hero(
                tag: 'review',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue.withOpacity(.1),
                      ),
                      child: TextButton.icon(
                        icon: Icon(
                          size: 16,
                          Icons.edit,
                          color: Colors.blue[700],
                        ),
                        label: Text(
                          'Edit',
                          style:
                          TextStyle(color: Colors.blue[700], fontSize: 15),
                        ),
                        onPressed: () {
                          Get.to(() =>
                              ClientReviewUpdate(leadId: review.leadId!,
                                  serviceProviderId: review.serviceProviderId!,
                                  review: review),transition: Transition.cupertino);
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
