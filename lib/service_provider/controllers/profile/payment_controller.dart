import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';

import '../../../client/widgets/custom_snackbar.dart';

class PaymentController extends GetxController {
  var cardNumber = ''.obs;
  var cardExpiry = ''.obs;
  var isLoading = false.obs;

  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardExpiryController = TextEditingController();

  void updateCardDetails(String cardNumber, String cardExpiry) async {
    isLoading.value = true;
    final UserController userController = Get.find();

    String month = cardExpiry.substring(0, 2);
    int monthInt = int.tryParse(month) ?? 0;

    if (monthInt > 12) {
      CustomSnackbar.showSnackBar(
        "Error",
        "Invalid expiry month. Month cannot be greater than 12.",
        const Icon(Icons.error, color: Colors.white),
        Colors.red,
        Get.context!,
      );
      isLoading.value = false;
      return;
    }
    if (userController.userModel.value!.cardNumber == cardNumber) {
      CustomSnackbar.showSnackBar(
        "Notice",
        "The card number you entered is the same as the previous one. If you'd like to update, please make sure the details are correct.",
        const Icon(Icons.info, color: Colors.white),
        Colors.orange,
        Get.context!,
      );
      isLoading.value = false;
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'cardNumber': cardNumber,
        'cardExpiry': cardExpiry,
      });

      await userController.fetchUser();
      cardNumberController.clear();
      cardExpiryController.clear();

      CustomSnackbar.showSnackBar(
        "Success",
        "Your card details have been updated.",
        const Icon(Icons.check_circle, color: Colors.white),
        Colors.green,
        Get.context!,
      );
    }

    isLoading.value = false;
  }

  String formatCardNumber(String text) {
    text = text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 16) {
      text = text.substring(0, 16);
    }

    String formattedText = '';
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formattedText += ' ';
      }
      formattedText += text[i];
    }
    return formattedText;
  }

  String formatExpiryDate(String text) {
    text = text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 4) {
      text = text.substring(0, 4);
    }

    if (text.length >= 3) {
      text = '${text.substring(0, 2)}/${text.substring(2, 4)}';
    }
    return text;
  }
}
