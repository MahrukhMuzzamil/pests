import 'package:flutter/material.dart';
import '../../../../../shared/models/lead_model/lead_model.dart';

Widget buildQuestionnaireSection(ThemeData theme,LeadModel
lead,bool isShown) {
  if (isShown) {
    return Card(
      color: Colors.white,
      child: ExpansionTile(
        title: Text(
          'Questionnaire',
          style: TextStyle(
            color: theme.colorScheme.primary,
          ),
        ),
        children: [
          buildQuestionAnswer('Pests', lead.pests.join(', ')),
          buildQuestionAnswer('Sightings Frequency', lead.sightingsFrequency),
          buildQuestionAnswer('Services', lead.services.join(', ')),
          buildQuestionAnswer('Hiring Decision', lead.hiringDecision),
          buildQuestionAnswer('Additional Details', lead.additionalDetails),
        ],
      ),
    );
  } else {
    return ExpansionTile(
      title: Text(
        'Questionnaire',
        style: TextStyle(
          color: theme.colorScheme.primary,
        ),
      ),
      children: [
        buildQuestionAnswer('Pests', lead.pests.join(', ')),
        buildQuestionAnswer('Sightings Frequency', lead.sightingsFrequency),
        buildQuestionAnswer('Services', lead.services.join(', ')),
        buildQuestionAnswer('Hiring Decision', lead.hiringDecision),
        buildQuestionAnswer('Additional Details', lead.additionalDetails),
      ],
    );
  }
}

Widget buildQuestionAnswer(String question, String answer) {
  return ListTile(
    title: Text(
      question,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
    subtitle: Text(answer),
  );
}