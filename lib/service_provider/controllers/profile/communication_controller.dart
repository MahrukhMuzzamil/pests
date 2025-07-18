import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../client/controllers/user/user_controller.dart';
import '../../../client/widgets/custom_snackbar.dart';

class CommunicationController extends GetxController {
  var emailTemplate = ''.obs;
  var smsTemplate = ''.obs;
  var isLoading = false.obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController smsController = TextEditingController();

  void setEmailInfo(String emailInfo) {
    emailTemplate.value = emailInfo;

    emailController.text = emailInfo;
  }

  void setSMSInfo(String smsInfo) {
    smsTemplate.value = smsInfo;

    smsController.text = smsInfo;
  }

  bool get isEmailChanged {
    final UserController userController = Get.find();

    return (userController.userModel.value!.emailTemplate !=
        emailTemplate.value);
  }

  bool get isSMSChanged {
    final UserController userController = Get.find();

    return (userController.userModel.value!.smsTemplate != smsTemplate.value);
  }

  Future<void> updateEmailTemplate(String newTemplate) async {
    try {
      final UserController userController = Get.find();
      isLoading.value = true;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userController.userModel.value!.uid)
          .update({
        'emailTemplate': newTemplate,
      });

      await userController.fetchUser();
      setEmailInfo(emailTemplate.value);
      isLoading.value = false;
      // Show success snackbar
      CustomSnackbar.showSnackBar(
        'Success',
        'Email template updated successfully.',
        const Icon(Icons.check, color: Colors.green),
        Colors.green,
        Get.context!,
      );

    } catch (e) {
      // Show error snackbar if update fails
      CustomSnackbar.showSnackBar(
        'Error',
        'Failed to update SMS template. Please try again.',
        const Icon(Icons.error, color: Colors.red),
        Colors.red,
        Get.context!,
      );
      print("Error updating email template: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSmsTemplate(String newTemplate) async {
    try {
      final UserController userController = Get.find();
      isLoading.value = true;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userController.userModel.value!.uid)
          .update({
        'smsTemplate': newTemplate,
      });


      await userController.fetchUser();
      setEmailInfo(emailTemplate.value);
      isLoading.value = false;

      // Show success snackbar
      CustomSnackbar.showSnackBar(
        'Success',
        'SMS template updated successfully.',
        const Icon(Icons.check, color: Colors.green),
        Colors.green,
        Get.context!,
      );

    } catch (e) {
      // Show error snackbar if update fails
      CustomSnackbar.showSnackBar(
        'Error',
        'Failed to update SMS template. Please try again.',
        const Icon(Icons.error, color: Colors.red),
        Colors.red,
        Get.context!,
      );
      print("Error updating SMS template: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
