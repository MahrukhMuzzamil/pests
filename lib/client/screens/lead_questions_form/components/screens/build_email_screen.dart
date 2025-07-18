import 'package:flutter/material.dart';
import '../../../../controllers/lead_question_form/lead_question_form_controller.dart';
import '../../../../widgets/custom_text_field.dart';
import '../widgets/build_page_widget.dart';

Widget buildEmailScreen(LeadsFormController controller) {
  return buildPage(
    title: 'What email address would you like quotes sent to?',
    child: buildTextField(
      onChanged:(value) => controller.email.value = value,
      controller: controller.emailController,
      labelText: 'Enter account email',
      prefixIcon: Icons.email,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email cannot be empty';
        } else if (!RegExp(
            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
            .hasMatch(value)) {
          return 'Enter a valid email';
        }
        return null;
      },
    ),
  );
}