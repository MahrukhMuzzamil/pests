import 'dart:io'; // Import to check platform
import 'package:flutter/cupertino.dart'; // Import for iOS style dialog
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/service_provider/controllers/leads/purchased_leads_controller.dart';
import '../../../../../client/controllers/user/user_controller.dart';
import '../../../../../client/screens/on_board/start.dart';
import '../../../../../client/widgets/custom_button.dart';
import '../../../../../client/widgets/custom_snackbar.dart';
import '../../../../../shared/models/lead_model/lead_model.dart';
import '../../../../controllers/leads/leads_controller.dart';

Widget buildContactNowButton(
    BuildContext context, LeadModel lead, bool isShown, bool isLoggedIn) {
  final LeadsController leadsController = Get.find();
  final UserController userController = Get.find();

  Future<bool> showConfirmationDialog() async {
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Platform.isIOS
            ? CupertinoAlertDialog(
                title: const Text('Confirm Purchase'),
                content: const Text(
                    'Are you sure you want to contact this lead? This action will deduct credits from your account.'),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  CupertinoDialogAction(
                    child: const Text('Confirm'),
                    isDefaultAction: true,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              )
            : AlertDialog(
                title: const Text('Confirm Purchase'),
                content: const Text(
                    'Are you sure you want to contact this lead? This action will deduct credits from your account.'),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  TextButton(
                    child: const Text('Confirm'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              );
      },
    );
    return isConfirmed ?? false;
  }

  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 45),
      child: CustomButton(
        onPressed: () async {
          final purchaseLeadController = Get.find<PurchasedLeadsController>();
          final isConfirmed = await showConfirmationDialog();
          if (isConfirmed) {
            if (isLoggedIn) {
              await leadsController.purchaseLead(lead);
              await userController.fetchUser();
              await purchaseLeadController.fetchPurchasedLeads();
            } else {
              CustomSnackbar.showSnackBar(
                'You are almost there!',
                'Please login to continue',
                const Icon(Icons.error),
                Theme.of(context).colorScheme.primary,
                context,
              );
              Get.to(() => const StartPage(), transition: Transition.cupertino);
            }
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        text: 'Contact Now',
        height: 40,
        isLoading: false,
        textStyle: const TextStyle(
          fontSize: 15,
          letterSpacing: 0.5,
          color: Colors.white,
        ),
        tag: '',
      ),
    ),
  );
}
