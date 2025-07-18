import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../../client/widgets/custom_button.dart';
import '../../../../../client/widgets/custom_snackbar.dart';
import '../../../../../client/widgets/custom_text_field.dart';
import '../../../../../shared/models/lead_model/lead_model.dart';
import '../../../../controllers/leads/purchased_leads_controller.dart';
import '../../../../models/buyer/buyer_model.dart';

Widget buildQuoteSection(ThemeData theme, LeadModel lead) {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController additionalDetailsController = TextEditingController();
  String selectedFeeType = 'One time fee';

  lead.buyers.firstWhere(
        (buyer) => buyer.userId == FirebaseAuth.instance.currentUser!.uid,
    orElse: () => Buyer(userId: '', status: '', activityLogs: []),
  );

  return Card(
    elevation: 1,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: ExpansionTile(
      title: Text(
        'Send Quote',
        style: TextStyle(
          color: theme.colorScheme.primary,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField(
                controller: amountController,
                labelText: 'Amount',
                prefixIcon: Icons.attach_money,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedFeeType,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedFeeType = newValue;
                  }
                },
                dropdownColor: Colors.white,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blue.withOpacity(1)),
                  ),
                ),
                items: <String>[
                  'One time fee',
                  'Per visit fee',
                  'Per session fee',
                  'Per week',
                  'Per month',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              buildTextField(
                controller: additionalDetailsController,
                labelText: 'Any other details?',
                prefixIcon: Icons.info_outline,
                keyboardType: TextInputType.text,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Send Estimate',
                textStyle: const TextStyle(fontSize: 15, color: Colors.white),
                onPressed: () {
                  double price = double.tryParse(amountController.text) ?? 0.0;
                  String additionalDetails = additionalDetailsController.text;

                  if (price > 0) {
                    _showConfirmationDialog(
                      theme: theme,
                      onConfirm: () async {
                        await Get.find<PurchasedLeadsController>().sendQuote(
                          lead,
                          price,
                          selectedFeeType,
                          additionalDetails,
                        );
                        amountController.clear();
                        additionalDetailsController.clear();
                        selectedFeeType = 'One time fee';
                      },
                    );
                  } else {
                    CustomSnackbar.showSnackBar(
                      'Error',
                      'Please enter a valid amount.',
                      const Icon(Icons.error, color: Colors.red),
                      Colors.red,
                      Get.context!,
                    );
                  }
                },
                isLoading: false,
                tag: 'send_estimate',
                height: 45,
                backgroundColor: theme.colorScheme.primary,
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

void _showConfirmationDialog({required ThemeData theme, required VoidCallback onConfirm}) {
  final isIOS = Theme.of(Get.context!).platform == TargetPlatform.iOS;

  showDialog(
    context: Get.context!,
    builder: (context) {
      return isIOS
          ? CupertinoAlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to send this quote?'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Get.back(),
          ),
          CupertinoDialogAction(
            child: const Text('Send'),
            onPressed: () {
              onConfirm();
              Get.back();
            },
          ),
        ],
      )
          : AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to send this quote?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Get.back(),
          ),
          TextButton(
            child: const Text('Send'),
            onPressed: () {
              onConfirm();
              Get.back();
            },
          ),
        ],
      );
    },
  );
}
