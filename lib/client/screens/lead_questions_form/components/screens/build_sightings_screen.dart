import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/controllers/lead_question_form/lead_question_form_controller.dart';
import '../widgets/build_page_widget.dart';

Widget buildSightingsScreen(LeadsFormController controller) {
  final sightings = [
    'I see the pest all the time',
    'I have seen the pests more than once',
    'I rarely see the pest',
    'I have not seen the pest yet',
    'I see the pest occasionally'
  ]; // Added more options and removed "Other"

  return buildPage(
    title: 'How many sightings have you had?',
    child: Column(
      children: sightings.map((sighting) {
        return Obx(() => RadioListTile<String>(
          title: Text(sighting),
          value: sighting,
          groupValue: controller.sightingsFrequency.value,
          onChanged: (value) {
            controller.sightingsFrequency.value = value!;
          },
        ));
      }).toList(),
    ),
  );
}
