import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/models/others/request.dart';

import 'package:pests247/client/controllers/lead_question_form/lead_question_form_controller.dart';



import '../widgets/build_page_widget.dart';

Widget buildServicesScreen(LeadsFormController controller) {
  final services = [
    'Inspection',
    'Fumigation',
    'Removal/Extermination',
    'As recommended by professional'
  ];

  return buildPage(
    title: 'What services do you need?',
    child: Column(
      children: services.map((service) {
        return Obx(() => CheckboxListTile(
          title: Text(service),
          value: controller.selectedServices.contains(service),
          onChanged: (bool? selected) {
            if (selected == true) {
              controller.selectedServices.add(service);
            } else {
              controller.selectedServices.remove(service);
            }
          },
        ));
      }).toList(),
    ),
  );
}