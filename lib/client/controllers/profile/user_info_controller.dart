import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';
import 'package:pests247/client/widgets/custom_snackbar.dart';
import 'package:pests247/shared/models/user/user_model.dart';

class ClientUserInfoController extends GetxController {
  var userName = ''.obs;
  var email = ''.obs;
  var contactNumber = ''.obs;
  var isLoading = false.obs;

  late TextEditingController userNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void onInit() {
    super.onInit();
    userNameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
  }

  void setUserInfo(String name, String email, String phone) {
    userNameController.text = name;
    emailController.text = email;
    phoneController.text = phone;

    userName.value = name;
    this.email.value = email;
    contactNumber.value = phone;
  }

  // Computed property to check if user information has changed
  bool get isChanged {
    UserController userController = Get.find();
    UserModel? userModel = userController.userModel.value;

    return userName.value != userModel!.userName ||
        email.value != userModel.email ||
        contactNumber.value != userModel.phone;
  }

  Future<void> updateUserInfo() async {
    UserController userController = Get.find();
    UserModel? userModel = userController.userModel.value;
    isLoading.value = true;

    if (isChanged) {
      try {
        // Get reference to Firestore user document
        DocumentReference userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userModel!.uid);

        // Update user information in Firestore
        await userRef.update({
          'userName': userName.value,
          'email': email.value,
          'phone': contactNumber.value,
        });

        // Update userModel to reflect changes
        await userController.fetchUser();
        setUserInfo(userName.value, email.value, contactNumber.value);
        isLoading.value = false;

        // Show success snackbar
        CustomSnackbar.showSnackBar(
          'Success',
          'Profile updated successfully.',
          const Icon(Icons.check, color: Colors.green),
          Colors.green,
          Get.context!,
        );
      } catch (e) {
        isLoading.value = false;

        // Log the error message for debugging
        print('Error updating profile: $e');

        // Show error snackbar if update fails
        CustomSnackbar.showSnackBar(
          'Error',
          'Failed to update profile. Please try again.',
          const Icon(Icons.error, color: Colors.red),
          Colors.red,
          Get.context!,
        );
      }
    } else {
      isLoading.value = false;
      // Show info snackbar if no changes were made
      CustomSnackbar.showSnackBar(
        'Info',
        'No changes detected.',
        const Icon(Icons.info, color: Colors.blue),
        Colors.blue,
        Get.context!,
      );
    }
  }

  @override
  void onClose() {
    userNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
