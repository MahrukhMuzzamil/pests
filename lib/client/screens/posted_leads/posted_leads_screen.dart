import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/screens/posted_leads/components/posted_lead_card.dart';
import '../../controllers/posted_leads/posted_leads_controller.dart';
import 'posted_lead_details_screen.dart';

class PostedLeadsScreen extends StatelessWidget {
  const PostedLeadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final postedLeadsController = Get.put(PostedLeadsController());
    postedLeadsController.fetchPostedLeads();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Posted Leads', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text(
                    'Review your requests and track provider responses. Tap a lead to see full details.',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (postedLeadsController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
        
                if (postedLeadsController.postedLeads.isEmpty) {
                  return const Center(
                    child: Text(
                      'No posted leads yet. Post a job from Home to get quotes from nearby providers.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
        
                return RefreshIndicator(
                  onRefresh: postedLeadsController.fetchPostedLeads,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: postedLeadsController.postedLeads.length,
                    itemBuilder: (context, index) {
                      final lead = postedLeadsController.postedLeads[index];
                      return GestureDetector(
                        onTap: () => Get.to(
                          () => PostedLeadDetailsScreen(
                            lead: lead,
                          ),
                          transition: Transition.cupertino,
                        ),
                        child: PostedLeadCard(
                          lead: lead,
                          isShown: true,
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

