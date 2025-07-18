import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/controllers/lead_question_form/lead_question_form_controller.dart';
import 'package:pests247/client/widgets/custom_text_field.dart';
import '../widgets/build_page_widget.dart';

Widget buildAdditionalDetailsScreen(LeadsFormController controller) {
  return buildPage(
    title: 'Additional Details',
    child: Column(
      children: [
        buildTextField(
            onChanged:(value) => controller.additionalDetails.value = value,
            controller: controller.additionalDetailsController,
          labelText: "Please provide additional details",
          prefixIcon: Icons.info,
          minLines: 5
        ),
      ],
    ),
  );
}
