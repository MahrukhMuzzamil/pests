import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';
import 'package:pests247/client/widgets/custom_snackbar.dart';
import 'package:pests247/service_provider/models/company_info/company_info_model.dart';

class SocialMediaController extends GetxController {
  var facebook = ''.obs;
  var twitter = ''.obs;
  var links = ''.obs;
  var isLoading = false.obs;

  late TextEditingController facebookController;
  late TextEditingController twitterController;
  late TextEditingController linksController;

  CompanyInfo? get companyInfo =>
      Get.find<UserController>().userModel.value?.companyInfo;

  @override
  void onInit() {
    super.onInit();
    facebookController = TextEditingController();
    twitterController = TextEditingController();
    linksController = TextEditingController();

    if (companyInfo != null) {
      setSocialMediaInfo(
        facebook: companyInfo!.facebookLink ?? '',
        twitter: companyInfo!.twitterLink ?? '',
        links: companyInfo!.website ?? '',
      );
    }
  }

  void setSocialMediaInfo(
      {required String facebook,
      required String twitter,
      required String links}) {
    facebookController.text = facebook;
    twitterController.text = twitter;
    linksController.text = links;

    this.facebook.value = facebook;
    this.twitter.value = twitter;
    this.links.value = links;
  }

  bool get isChanged {
    final UserController userController = Get.find<UserController>();

    return facebook.value != (userController.userModel.value?.companyInfo?.facebookLink ?? '') ||
        twitter.value != (userController.userModel.value?.companyInfo?.twitterLink ?? '') ||
        links.value != (userController.userModel.value?.companyInfo?.website ?? '');
  }


  Future<void> updateSocialMediaInfo() async {
    final UserController userController = Get.find<UserController>();

    isLoading.value = true;

    if (isChanged) {
      try {
        // Get all existing fields from companyInfo and update only the changed ones
        final existing = this.companyInfo;
        // Use toMap() if available for consistency
        Map<String, dynamic> companyInfo = existing != null ? existing.toMap() : {};
        // Update only the social media fields
        companyInfo['website'] = links.value.isNotEmpty ? links.value : (existing?.website ?? '');
        companyInfo['twitterLink'] = twitter.value.isNotEmpty ? twitter.value : (existing?.twitterLink ?? '');
        companyInfo['facebookLink'] = facebook.value.isNotEmpty ? facebook.value : (existing?.facebookLink ?? '');

        // Update the company info in the user's document
        DocumentReference userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userController.userModel.value!.uid);

        await userRef.update({
          'companyInfo': companyInfo,
        });
        await userController.fetchUser();
        setSocialMediaInfo(
          facebook: facebook.value,
          twitter: twitter.value,
          links: links.value,
        );

        isLoading.value = false;

        CustomSnackbar.showSnackBar(
          'Success',
          'Company information updated successfully.',
          const Icon(Icons.check, color: Colors.green),
          Colors.green,
          Get.context!,
        );
      } catch (e) {
        isLoading.value = false;
        print('Error updating company information: $e');
        CustomSnackbar.showSnackBar(
          'Error',
          'Failed to update information. Please try again.',
          const Icon(Icons.error, color: Colors.red),
          Colors.red,
          Get.context!,
        );
      }
    } else {
      isLoading.value = false;
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
    facebookController.dispose();
    twitterController.dispose();
    linksController.dispose();
    super.onClose();
  }
}
