import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/widgets/custom_button.dart';
import 'package:pests247/client/widgets/custom_text_field.dart';

import '../../../../controllers/profile/change_password_controller.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChangePasswordController passwordController = Get.put(ChangePasswordController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Keep your account secure by updating your password regularly. Choose a strong, unique password to protect your information.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              const Text(
                'Enter your current password.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              buildTextField(
                prefixIcon: Icons.lock,
                controller: passwordController.oldPasswordController,
                labelText: '',
                onChanged: (value) {
                  passwordController.oldPassword.value = value;
                },
                maxLines: 1,
                obscureText: true,
              ),
              const SizedBox(height: 20),

              const Text(
                'Enter your new password.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              buildTextField(
                prefixIcon: Icons.lock_outline,
                controller: passwordController.newPasswordController,
                labelText: '',
                onChanged: (value) {
                  passwordController.newPassword.value = value;
                },
                maxLines: 1,
                obscureText: true,
              ),
              const SizedBox(height: 20),

              const Text(
                'Confirm your new password.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              buildTextField(
                prefixIcon: Icons.lock_outline,
                controller: passwordController.confirmPasswordController,
                labelText: '',
                onChanged: (value) {
                  passwordController.confirmPassword.value = value;
                },
                maxLines: 1,
                obscureText: true,
              ),
              const SizedBox(height: 60),

              Obx(() {
                return CustomButton(
                  height: 45,
                  text: 'Update Password',
                  textStyle: const TextStyle(fontSize: 15,color: Colors.white),
                  onPressed: passwordController.isChanged
                      ? () {
                    passwordController.updatePassword();
                  }
                      : () => {},
                  isLoading: passwordController.isLoading.value,
                  backgroundColor: passwordController.isChanged
                      ? Colors.blue
                      : Colors.grey,
                  tag: '',
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
