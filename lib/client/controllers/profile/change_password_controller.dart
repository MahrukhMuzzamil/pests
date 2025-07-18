import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pests247/client/widgets/custom_snackbar.dart';

class ClientChangePasswordController extends GetxController {
  var oldPassword = ''.obs;
  var newPassword = ''.obs;
  var confirmPassword = ''.obs;
  var isLoading = false.obs;

  late TextEditingController oldPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  @override
  void onInit() {
    super.onInit();
    oldPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  bool get isChanged {
    return oldPassword.isNotEmpty &&
        newPassword.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        newPassword.value == confirmPassword.value &&
        newPassword.value != oldPassword.value;
  }

  Future<void> updatePassword() async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    if (newPassword.value != confirmPassword.value) {
      CustomSnackbar.showSnackBar(
        'Error',
        'Passwords do not match.',
        const Icon(Icons.error, color: Colors.red),
        Colors.red,
        Get.context!,
      );
      return;
    }

    if (newPassword.value == oldPassword.value) {
      CustomSnackbar.showSnackBar(
        'Error',
        'New password cannot be the same as the old password.',
        const Icon(Icons.error, color: Colors.red),
        Colors.red,
        Get.context!,
      );
      return;
    }

    try {
      isLoading.value = true;

      User? user = auth.currentUser;

      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: oldPassword.value,
      );

      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword.value);

      isLoading.value = false;

      CustomSnackbar.showSnackBar(
        'Success',
        'Password updated successfully.',
        const Icon(Icons.check, color: Colors.green),
        Colors.green,
        Get.context!,
      );
    } catch (e) {
      isLoading.value = false;
      CustomSnackbar.showSnackBar(
        'Error',
        'Failed to update password. Please try again.',
        const Icon(Icons.error, color: Colors.red),
        Colors.red,
        Get.context!,
      );
    }
  }

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
