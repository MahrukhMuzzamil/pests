import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/controllers/lead_question_form/lead_question_form_controller.dart';

import '../widgets/build_page_widget.dart';

Widget buildPropertyTypeScreen(LeadsFormController controller) {
  final propertyTypes = ['Residential', 'Commercial', 'Industrial', 'Retail', 'Agricultural']; // Added new options

  return buildPage(
    title: 'What is the type of property?',
    child: Column(
      children: [
        ...propertyTypes.map((type) {
          return Obx(() => RadioListTile<String>(
            title: Text(type),
            value: type,
            groupValue: controller.selectedPropertyType.value,
            onChanged: (value) {
              controller.selectedPropertyType.value = value!;
            },
          ));
        }),
      ],
    ),
  );
}
