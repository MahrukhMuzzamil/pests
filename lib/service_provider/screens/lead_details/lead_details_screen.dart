import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/service_provider/screens/lead_details/components/widgets/build_activity_logs.dart';
import 'package:pests247/service_provider/screens/lead_details/components/widgets/build_quote_estimate.dart';
import 'package:pests247/service_provider/controllers/leads/purchased_leads_controller.dart';
import '../leads/components/widgets/build_question_answer.dart';
import 'components/widgets/build_contact.dart';
import 'components/widgets/build_header.dart';
import 'components/widgets/build_shimmer.dart';

class LeadDetailScreen extends StatelessWidget {
  final String leadId;
  final String status;

  const LeadDetailScreen(
      {super.key, required this.leadId, required this.status});

  @override
  Widget build(BuildContext context) {
    final PurchasedLeadsController leadsController = Get.find();
    final lead = leadsController.filteredLeads
        .firstWhere((lead) => lead.leadId == leadId);

    if (!leadsController.userDetailsMap.containsKey(lead.userId)) {
      leadsController.fetchUserDetailById(lead.userId);
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: Obx(() {
        final user = leadsController.userDetailsMap[lead.userId];
        return user == null
            ? buildFullShimmerPlaceholder(theme)
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildHeaderSection(context, lead, user),
                    const SizedBox(height: 20),
                    buildQuestionnaireSection(theme, lead,true),
                    const SizedBox(height: 10),
                    buildActivityLogsSection(theme, lead),
                    const SizedBox(height: 10),
                    buildQuoteSection(theme, lead),
                    const SizedBox(height: 30),
                    buildContacts(context, lead, user),
                    const SizedBox(height: 30),
                  ],
                ),
              );
      }),
    );
  }
}
