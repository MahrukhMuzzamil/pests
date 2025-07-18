import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';
import 'package:pests247/client/widgets/custom_button.dart';
import '../../../../controllers/profile/delete_account_controller.dart';

class ClientDeleteAccountScreen extends StatelessWidget {
  const ClientDeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ClientDeleteAccountController accountController = Get.put(ClientDeleteAccountController());
    final UserController userController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Delete Account',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
            Text(
              'Username: ${userController.userModel.value!.userName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Account Created: ${accountController.accountCreationDate}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Description Section
            const Text(
              'This action is irreversible. All your leads, saved data, chat history, and related preferences will be permanently deleted.',
              style: TextStyle(fontSize: 14, color: Colors.red),
            ),
            const SizedBox(height: 40),

            // Expanded widget to push the button to the bottom
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Delete Account Button
                  Obx(() {
                    return CustomButton(
                      height: 45,
                      text: 'Delete Account',
                      textStyle: const TextStyle(fontSize: 15,color: Colors.white),
                      onPressed: accountController.isLoading.value
                          ? () => {}
                          : () {
                        accountController.confirmDeleteAccount();
                      },
                      isLoading: accountController.isLoading.value,
                      backgroundColor: Colors.red,
                      tag: '',
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
