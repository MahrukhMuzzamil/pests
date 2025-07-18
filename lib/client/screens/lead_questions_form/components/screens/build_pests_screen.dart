import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/models/others/request.dart';

import 'package:pests247/client/controllers/lead_question_form/lead_question_form_controller.dart';



import '../widgets/build_page_widget.dart';

Widget buildPestsScreen(LeadsFormController controller) {
  final pests = [
    'Rodents: Roof rats, house mouse, other rodents',
    'Cockroaches: German, American, Albino, etc.',
    'Ants: Carpenter ants, Mexican ants, others',
    'Stinging Pests: Bed bugs, Bees, Mosquitoes',
    'Termites: Subterranean, Damp wood termites',
    'Flies: Common flies, Biting flies',
    'Other Pests: Fleas, Moths, Ticks, etc.'
  ];

  return buildPage(
    title: 'Which pest(s) need controlling?',
    child: Column(
      children: pests.map((pest) {
        return Obx(() => CheckboxListTile(
          title: Text(pest),
          value: controller.selectedPests.contains(pest),
          onChanged: (bool? selected) {
            if (selected == true) {
              controller.selectedPests.add(pest);
            } else {
              controller.selectedPests.remove(pest);
            }
          },
        ));
      }).toList(),
    ),
  );
}