import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/lead_question_form/lead_question_form_controller.dart';
import '../widgets/build_page_widget.dart';

Widget buildHiringDecisionScreen(LeadsFormController controller) {
  final decisions = [
    'I’m ready to hire now',
    'I will definitely hire someone',
    'I’m likely to hire someone',
    'I will possibly hire someone',
    'I’m planning and researching',
  ];

  return buildPage(
    title: 'How likely are you to make a hiring decision?',
    child: Column(
      children: decisions.map((decision) {
        return Obx(() => RadioListTile<String>(
          title: Text(decision),
          value: decision,
          groupValue: controller.hiringDecision.value,
          onChanged: (value) {
            controller.hiringDecision.value = value!;
          },
        ));
      }).toList(),
    ),
  );
}