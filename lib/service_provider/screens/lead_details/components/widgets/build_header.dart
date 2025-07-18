import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../client/widgets/custom_snackbar.dart';
import '../../../../../shared/models/lead_model/lead_model.dart';
import '../../../../../shared/models/user/user_model.dart';
import '../../../../controllers/leads/purchased_leads_controller.dart';
import '../../../../models/buyer/buyer_model.dart';

Widget buildHeaderSection(
    BuildContext context, LeadModel lead, UserModel? user) {
  final theme = Theme.of(context);
  final PurchasedLeadsController purchasedLeadsController = Get.find();

  String initialStatus = lead.buyers
      .firstWhere(
          (buyer) => buyer.userId == FirebaseAuth.instance.currentUser!.uid,
      orElse: () => Buyer(userId: '', status: 'hired'))
      .status;

  purchasedLeadsController.currentStatus.value = initialStatus;

  Color getColorForStatus(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'hired':
        return Colors.indigo;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.grey;
      default:
        return Colors.indigo;
    }
  }

  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.primary.withOpacity(0.7),
          theme.colorScheme.primary,
          Colors.blueAccent,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                user?.profilePicUrl != null && user!.profilePicUrl!.isNotEmpty
                    ? CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(user.profilePicUrl!),
                )
                    : const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Text(
                  lead.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // Status dropdown
            Obx(() {
              Color statusColor = getColorForStatus(
                  purchasedLeadsController.currentStatus.value);
              return Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  dropdownColor: Colors.white,
                  value: purchasedLeadsController.currentStatus.value,
                  items: <String>['hired', 'completed', 'pending', 'rejected']
                      .map<DropdownMenuItem<String>>((String value) {
                    Icon icon;
                    Color color = getColorForStatus(value);

                    switch (value) {
                      case 'completed':
                        icon = const Icon(Icons.check_circle,
                            color: Colors.white, size: 19);
                        break;
                      case 'hired':
                        icon = const Icon(Icons.thumb_up,
                            color: Colors.white, size: 19);
                        break;
                      case 'pending':
                        icon = const Icon(Icons.circle,
                            color: Colors.red, size: 19);
                        break;
                      case 'rejected':
                        icon = const Icon(Icons.cancel,
                            color: Colors.white, size: 19);
                        break;
                      default:
                        icon = const Icon(Icons.help,
                            color: Colors.white, size: 19);
                        break;
                    }

                    return DropdownMenuItem<String>(
                      value: value,
                      child: Container(
                        color: color,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 5),
                        child: Row(
                          children: [
                            icon,
                            const SizedBox(width: 10),
                            Text(value,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) async {
                    if (newValue != null && newValue != 'hired') {
                      await purchasedLeadsController.updateLeadStatus(
                          lead, newValue);
                    }
                    else
                      {
                        CustomSnackbar.showSnackBar(
                          'Error',
                          'You can not change status to Hired',
                          const Icon(Icons.error, color: Colors.red),
                          Colors.red,
                          Get.context!,
                        );
                      }
                  },
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 8),
        buildInfoRow(Icons.email, 'Email', user?.email ?? 'N/A',
            color: Colors.white),
        buildInfoRow(Icons.phone, 'Contact', user?.phone ?? 'N/A',
            color: Colors.white),
        buildInfoRow(Icons.location_on, 'Location', lead.location,
            color: Colors.white),
        buildInfoRow(
          Icons.date_range,
          'Submitted At',
          DateFormat('hh:mm a dd-MM-yyyy').format(lead.submittedAt),
          color: Colors.white,
        ),
      ],
    ),
  );
}

Widget buildInfoRow(IconData icon, String label, String value, {Color? color}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    child: Row(
      children: [
        Icon(icon, color: color ?? Colors.grey[700]),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
                color: color != null ? Colors.white70 : Colors.black54),
          ),
        ),
      ],
    ),
  );
}
