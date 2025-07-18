import 'package:flutter/material.dart';
import 'package:pests247/client/controllers/home/home_controller.dart';
import '../../../../controllers/lead_question_form/lead_question_form_controller.dart';
import '../../../../controllers/user/user_controller.dart';
import '../../../../widgets/custom_text_field.dart';
import '../widgets/build_page_widget.dart';

Widget buildConfirmationScreen(
    BuildContext context, LeadsFormController controller, UserController userController) {
  return buildPage(
    title: 'Please review your information',
    child: Column(
      children:[
        Card(
          color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Section
              Row(
                children: [
                  ClipOval(
                    child: (userController.userModel.value?.profilePicUrl?.isNotEmpty ?? false)
                        ? Image.network(
                      userController.userModel.value!.profilePicUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                        : const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (userController.userModel.value?.userName?.isNotEmpty ?? false)
                              ? userController.userModel.value!.userName
                              : 'Username not set',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userController.userModel.value?.email ?? 'Email not set',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Confirmation Details Section
              const Text(
                'Confirmation Details',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: const Text('Property Type:'),
                subtitle: Text(controller.selectedPropertyType.value.isNotEmpty
                    ? controller.selectedPropertyType.value
                    : 'Not specified'),
              ),
              ListTile(
                title: const Text('Selected Pests:'),
                subtitle: Text(controller.selectedPests.isNotEmpty
                    ? controller.selectedPests.join(', ')
                    : 'No pests selected'),
              ),
              ListTile(
                title: const Text('Sightings Frequency:'),
                subtitle: Text(controller.sightingsFrequency.value.isNotEmpty
                    ? controller.sightingsFrequency.value
                    : 'Not specified'),
              ),
              ListTile(
                title: const Text('Services Needed:'),
                subtitle: Text(controller.selectedServices.isNotEmpty
                    ? controller.selectedServices.join(', ')
                    : 'No services selected'),
              ),
              ListTile(
                title: const Text('Hiring Decision:'),
                subtitle: Text(controller.hiringDecision.value.isNotEmpty
                    ? controller.hiringDecision.value
                    : 'Not specified'),
              ),
              ListTile(
                title: const Text('Location:'),
                subtitle: Text(controller.location.value.isNotEmpty
                    ? controller.location.value
                    : 'Not specified'),
              ),ListTile(
                title: const Text('Additional Details:'),
                subtitle: Text(controller.additionalDetails.value.isNotEmpty
                    ? controller.additionalDetails.value
                    : 'Not specified'),
              ),
            ],
          ),
        ),
      ),
        const SizedBox(height: 20),
        const Text(
          'Please verify your identity here to submit a lead.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 25),
        // Email and Password Fields
        buildTextField(
          controller: controller.emailController,
          labelText: 'Email Address',
          prefixIcon: Icons.email,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        buildTextField(
          maxLines: 1,
          controller: controller.passwordController,
          labelText: 'Password',
          prefixIcon: Icons.lock,
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
        ),
      ]
    ),
  );
}
