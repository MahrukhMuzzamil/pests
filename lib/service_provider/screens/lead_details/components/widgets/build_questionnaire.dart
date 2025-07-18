
import 'package:flutter/material.dart';

import '../../../../../shared/models/lead_model/lead_model.dart';

Widget buildQuestionnaireSections(ThemeData theme, LeadModel lead) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Questionnaire',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 10),
        buildQuestionAnswer('Pests', lead.pests.join(', ')),
        buildQuestionAnswer('Sightings Frequency', lead.sightingsFrequency),
        buildQuestionAnswer('Services', lead.services.join(', ')),
        buildQuestionAnswer('Hiring Decision', lead.hiringDecision),
        buildQuestionAnswer('Additional Details', lead.additionalDetails),
      ],
    ),
  );
}

Widget buildQuestionAnswer(String question, String answer) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: ListTile(
      title: Text(
        question,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black.withOpacity(.3),
        ),
      ),
      subtitle: Text(
        answer,
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
    ),
  );
}