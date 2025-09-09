import 'package:flutter/material.dart';
import '../../../../../shared/models/lead_model/lead_model.dart';
import 'build_contact_now_button.dart';
import 'build_header_section.dart';
import 'build_info_section.dart';
import 'build_question_answer.dart';

class LeadCard extends StatelessWidget {
  final LeadModel lead;
  final String status;
  final bool isShown;
  final bool isLoggedIn;

  const LeadCard(
      {super.key, required this.lead, required this.status, required this.isShown, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final relativeTime = _getRelativeTime(lead.submittedAt);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(theme, lead.name, relativeTime, status, isShown),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            buildInfoSection(theme, lead, isShown),
            const SizedBox(height: 12),
            if (!isShown) buildQuestionnaireSection(theme, lead, isShown),
            if (!isShown) const SizedBox(height: 12),
            if (!isShown) buildContactNowButton(context, lead, isShown, isLoggedIn),
          ],
        ),
      ),
    );
  }

  String _getRelativeTime(DateTime submittedAt) {
    final now = DateTime.now();
    final submittedDate =
        DateTime(submittedAt.year, submittedAt.month, submittedAt.day);
    final currentDate = DateTime(now.year, now.month, now.day);

    final difference = currentDate.difference(submittedDate);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return '1 day ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
