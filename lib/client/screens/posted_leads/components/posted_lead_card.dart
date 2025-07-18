import 'package:flutter/material.dart';
import '../../../../../shared/models/lead_model/lead_model.dart';
import '../../../../service_provider/screens/leads/components/widgets/build_contact_now_button.dart';
import '../../../../service_provider/screens/leads/components/widgets/build_header_section.dart';
import '../../../../service_provider/screens/leads/components/widgets/build_info_section.dart';
import '../../../../service_provider/screens/leads/components/widgets/build_question_answer.dart';

class PostedLeadCard extends StatelessWidget {
  final LeadModel lead;
  final bool isShown;

  const PostedLeadCard(
      {super.key, required this.lead, required this.isShown});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final relativeTime = _getRelativeTime(lead.submittedAt);

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 6,
      child: ClipPath(
        clipper: ShapeBorderClipper(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: theme.colorScheme.primary,
                width: 8,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(theme, lead.name, relativeTime,lead.status,isShown),
                const SizedBox(height: 16),
                buildInfoSection(theme, lead, isShown),
                const SizedBox(height: 16),
                if (!isShown) buildQuestionnaireSection(theme, lead,isShown),
                if (!isShown) const SizedBox(height: 16),
                if (!isShown) buildContactNowButton(context, lead, isShown,true),
              ],
            ),
          ),
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
