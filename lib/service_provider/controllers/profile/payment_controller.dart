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
    // PCI-DSS: Do not collect or store full card numbers/expiry in Firestore.
    // Cards are handled securely by Stripe PaymentSheet.
    isLoading.value = true;
    try {
      final UserController userController = Get.find();
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Purge any previously stored sensitive fields if present
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'cardNumber': FieldValue.delete(),
          'cardExpiry': FieldValue.delete(),
        });
        await userController.fetchUser();
      }

      cardNumberController.clear();
      cardExpiryController.clear();

      CustomSnackbar.showSnackBar(
        "Managed by Stripe",
        "Cards are saved and managed securely by Stripe. We don't store card numbers.",
        const Icon(Icons.lock, color: Colors.white),
        Colors.blue,
        Get.context!,
      );
    } finally {
      isLoading.value = false;
    }
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
