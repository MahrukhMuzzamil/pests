import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../../shared/models/lead_model/lead_model.dart';
import '../../../../../../shared/models/user/user_model.dart';
import '../../../../../service_provider/models/buyer/buyer_model.dart';

Widget buildPostedLeadHeader(
    BuildContext context, LeadModel lead, UserModel? user) {
  final theme = Theme.of(context);

  String currentStatus = lead.status;

  Color getColorForStatus(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.grey;
      case 'hired':
        return Colors.indigo;
      case 'rejected':
        return Colors.red;
      default: // all
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
            // Display Status as a static field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: getColorForStatus(currentStatus),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    currentStatus == 'completed'
                        ? Icons.check_circle
                        : currentStatus == 'pending'
                            ? Icons.circle
                            : currentStatus == 'hired'
                                ? Icons.thumb_up
                                : currentStatus == 'rejected'
                                    ? Icons.cancel
                                    : Icons.help,
                    color:
                        currentStatus == 'completed' || currentStatus == 'hired'
                            ? Colors.white
                            : currentStatus == 'pending'
                                ? Colors.red
                                : Colors.white,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentStatus,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
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
