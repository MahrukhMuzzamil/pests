import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';
import 'package:pests247/client/widgets/custom_button.dart';
import 'package:pests247/client/widgets/custom_text_field.dart';
import '../../../../controllers/profile/communication_controller.dart';

class EmailTemplateScreen extends StatelessWidget {
  const EmailTemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CommunicationController controller =
        Get.put(CommunicationController());
    final UserController userController = Get.find();

    controller.setEmailInfo(userController.userModel.value!.emailTemplate!);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Email Template',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const Text(
                    'Enter the email template content below. This will be used when sending email notifications.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  buildTextField(
                    controller: controller.emailController,
                    onChanged: (value) {
                      controller.emailTemplate.value = value;
                    },
                    minLines: 6,
                    labelText: '',
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: CustomButton(
                  height: 45,
                  backgroundColor: controller.isEmailChanged ? Colors.blue : Colors.grey,
                  textStyle: const TextStyle(fontSize: 15, color: Colors.white),
                  onPressed: controller.isEmailChanged
                      ? () {
                          controller.updateEmailTemplate(
                              controller.emailTemplate.value);
                        }
                      : () => {},
                  text: 'Save',
                  isLoading: controller.isLoading.value,
                  tag: '',
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
