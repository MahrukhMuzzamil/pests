import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../shared/models/lead_model/lead_model.dart';

Widget buildInfoSection(ThemeData theme, LeadModel lead, bool isShown) {
  return Column(
    children: [
      buildInfoRow(
          Icons.email, 'Email', isShown ? lead.email : maskEmail(lead.email)),
      buildInfoRow(Icons.location_on, 'Location',
          isShown ? lead.location : maskPostalCode(lead.location)),
      buildCreditRow(
          Icons.credit_score, 'Credits', '${lead.credits}', lead.buyers.length),
      buildInfoRow(Icons.home, 'Property Type', lead.propertyType),
    ],
  );
}

String maskEmail(String email) {
  final parts = email.split('@');
  if (parts.length == 2) {
    final username = parts[0];
    final domain = parts[1];
    String maskedUsername = username.length > 4
        ? username.substring(0, 4) +
            '*' * (username.length - 5) +
            username.substring(username.length - 1)
        : username.replaceRange(
            1, username.length - 1, '*' * (username.length - 2));
    return '$maskedUsername@$domain';
  }
  return email;
}

String maskPostalCode(String location) {
  if (location.length > 3) {
    return location.substring(0, 3) + '*' * 4;
  }
  return location;
}

Widget buildInfoRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

Widget buildCreditRow(IconData icon, String label, String value, int buyers) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey[700]),
            const SizedBox(width: 12),
            Text(
              '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(value),
          ],
        ),
        Row(
          children: [
            // Dots representing the number of buyers
            Row(
              children: List.generate(2, (index) {
                return Container(
                  width: 15,
                  height: 15,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < buyers ? Colors.blue : Colors.grey,
                  ),
                );
              }),
            ),
            const SizedBox(width: 8),
            // Tooltip icon
            GestureDetector(
              onTap: () {
                _showInfoDialog(Get.context!);
              },
              child: Icon(Icons.info_outline, color: Colors.grey[700]),
            ),
          ],
        ),
      ],
    ),
  );
}

void _showInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Platform.isIOS
          ? CupertinoAlertDialog(
              title: const Text('Info'),
              content: const Text(
                  'Total persons who have purchased this lead. A maximum of 3 users can respond to this. '),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )
          : AlertDialog(
              title: const Text('Info'),
              content: const Text(
                  'Total persons who have purchased this lead. A maximum of 3 users can respond to this. '),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
    },
  );
}
