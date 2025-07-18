import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../client/widgets/custom_button.dart';
import '../../../../../client/widgets/custom_snackbar.dart';
import '../../../../../client/widgets/custom_text_field.dart';
import '../../../../controllers/profile/payment_controller.dart';

class ChangeCardScreen extends StatelessWidget {
  final PaymentController paymentController = Get.put(PaymentController());

  ChangeCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Card",style: TextStyle(fontWeight: FontWeight.bold),)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                // Header Description
                const Text(
                  "Please enter your new card details below to update your payment method.",
                  style: TextStyle(fontSize: 14, color: Colors.black38),
                ),
                const SizedBox(height: 20),

                // Card Number Field
                buildTextField(
                  controller: paymentController.cardNumberController,
                  labelText: "Card Number",
                  prefixIcon: Icons.credit_card,
                  keyboardType: TextInputType.number,
                  onChanged: (text) {
                    paymentController.cardNumberController.text =
                        paymentController.formatCardNumber(text);
                    paymentController.cardNumberController.selection = TextSelection.collapsed(
                        offset: paymentController.cardNumberController.text.length);
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "Enter the 16-digit card number. This can be found on the front of your credit or debit card.",
                  style: TextStyle(fontSize: 14, color: Colors.black38),
                ),
                const SizedBox(height: 20),

                // Expiry Date Field
                buildTextField(
                  controller: paymentController.cardExpiryController,
                  labelText: "Expiry Date (MM/YY)",
                  prefixIcon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                  onChanged: (text) {
                    paymentController.cardExpiryController.text =
                        paymentController.formatExpiryDate(text);
                    paymentController.cardExpiryController.selection = TextSelection.collapsed(
                        offset: paymentController.cardExpiryController.text.length);
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "Enter the card's expiry date in the format MM/YY, which can be found on the front of your card.",
                  style: TextStyle(fontSize: 14, color: Colors.black38),
                ),
                const SizedBox(height: 40),
              ],
            ),

            // Update Card Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: Obx(
                () => CustomButton(
                  height: 45,
                  textStyle: const TextStyle(fontSize: 15, color: Colors.white),
                  text: "Update Card",
                  onPressed: () {
                    String cardNumber = paymentController.cardNumberController.text.trim();
                    String cardExpiry = paymentController.cardExpiryController.text.trim();

                    if (cardNumber.isNotEmpty && cardExpiry.isNotEmpty) {
                      paymentController.updateCardDetails(cardNumber, cardExpiry);
                    } else {
                      CustomSnackbar.showSnackBar(
                        "Error",
                        "Please enter valid card details.",
                        const Icon(Icons.error, color: Colors.white),
                        Colors.red,
                        context,
                      );
                    }
                  },
                  backgroundColor: Colors.blue,
                  isLoading: paymentController.isLoading.value,
                  tag: '',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
