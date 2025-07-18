import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../client/controllers/user/user_controller.dart';
import '../../../../../client/widgets/custom_button.dart';
import '../../../../../client/widgets/custom_text_field.dart';
import '../../../../controllers/profile/communication_controller.dart';

class SmsTemplateScreen extends StatelessWidget {
  const SmsTemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CommunicationController controller =
    Get.put(CommunicationController());
    final UserController userController = Get.find();

    controller.setSMSInfo(userController.userModel.value!.smsTemplate!);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SMS Template',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Obx(() {
                  return IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enter the SMS template content below. This will be used when sending SMS notifications.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        buildTextField(
                          controller: controller.smsController,
                          onChanged: (value) {
                            controller.smsTemplate.value = value;
                          },
                          minLines: 6,
                          labelText: '',
                        ),
                        const Spacer(), // Pushes the button to the bottom
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: CustomButton(
                            height: 45,
                            backgroundColor: controller.isSMSChanged
                                ? Colors.blue
                                : Colors.grey,
                            textStyle: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                            onPressed: controller.isSMSChanged
                                ? () {
                              controller.updateSmsTemplate(
                                  controller.smsTemplate.value);
                            }
                                : () => {},
                            text: 'Save',
                            isLoading: controller.isLoading.value,
                            tag: '',
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}
