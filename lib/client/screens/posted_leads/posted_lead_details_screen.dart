import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/controllers/posted_leads/posted_leads_controller.dart';
import 'package:pests247/client/screens/posted_leads/components/widgets/buildPostedLeadActivity.dart';
import 'package:pests247/client/screens/posted_leads/components/widgets/buildPostedLeadHeader.dart';
import 'package:pests247/client/screens/posted_leads/components/widgets/buildPostedLeadQuestions.dart';
import 'package:pests247/client/screens/posted_leads/components/widgets/build_buyer_info_card.dart';
import 'package:pests247/client/screens/posted_leads/components/widgets/build_review_request_card.dart';
import '../../../service_provider/models/buyer/buyer_model.dart';
import '../../controllers/profile/user_review_controller.dart';
import '../../controllers/user/user_controller.dart';
import '../reviews/components/user_review_card.dart';
import '../../../shared/models/lead_model/lead_model.dart';

class PostedLeadDetailsScreen extends StatelessWidget {
  final LeadModel lead;

  const PostedLeadDetailsScreen({super.key, required this.lead});

  Future<void> refreshScreen(String serviceProviderId, String currentUserId) async {
    if (serviceProviderId.isEmpty || currentUserId.isEmpty) {
      return;
    }

    final reviewController = Get.find<ClientReviewController>();
    final postedLeadsController = Get.find<PostedLeadsController>();

    postedLeadsController.fetchPostedLeads();
    await reviewController.loadReview(serviceProviderId, currentUserId);
  }


  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final reviewController = Get.put(ClientReviewController());

    // Identify serviceProviderId and currentUserId
    List<Buyer> buyers = lead.buyers
        .where((buyer) => buyer.status == 'hired' || buyer.status == 'completed')
        .toList();
    List<Buyer> completedStatusBuyer = buyers.where((buyer) => buyer.status == 'completed').toList();

    // Check if completedStatusBuyer is empty
    String serviceProviderId = '';
    if (completedStatusBuyer.isNotEmpty) {
      serviceProviderId = completedStatusBuyer.first.userId;
    }

    final String currentUserId = userController.userModel.value!.uid;

    // Load initial review data
    if (serviceProviderId.isNotEmpty) {
      reviewController.loadReview(serviceProviderId, currentUserId);
    }

    return Scaffold(
      appBar: AppBar(),
      body: RefreshIndicator(
        onRefresh: () => refreshScreen(serviceProviderId, currentUserId),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildPostedLeadHeader(context, lead, userController.userModel.value),
              const SizedBox(height: 20),
              buildPostedLeadQuestions(Theme.of(context), lead, true),
              const SizedBox(height: 10),
              if (buyers.isNotEmpty) buildPostedLeadActivity(Theme.of(context), lead),
              const SizedBox(height: 15),
              if (lead.buyers.isNotEmpty && lead.status != 'completed')
                buildBuyerInfoCard(context, lead, userController.userModel.value!),
              const SizedBox(height: 10),

              if (lead.status == 'completed')
                Obx(() {
                  if (reviewController.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 6,)),
                    );
                  } else if (reviewController.review.value != null) {
                    return ClientReviewCard(
                      review: reviewController.review.value!,
                      rating: reviewController.review.value!.reviewUserRating.toInt(),
                    );
                  } else {
                    return ReviewRequestCard(
                      serviceProviderId: serviceProviderId,
                      leadId: lead.leadId,
                      lead: lead,
                    );
                  }
                }),
            ],
          ),
        ),
      ),
    );
  }
}
