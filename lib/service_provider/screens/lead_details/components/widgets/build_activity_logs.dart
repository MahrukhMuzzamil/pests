import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../shared/models/lead_model/lead_model.dart';
import '../../../../models/activity_logs/activity_logs_model.dart';
import '../../../../models/buyer/buyer_model.dart';

Widget buildActivityLogsSection(ThemeData theme, LeadModel lead) {
  final currentUserBuyer = lead.buyers.firstWhere(
        (buyer) => buyer.userId == FirebaseAuth.instance.currentUser!.uid,
    orElse: () => Buyer(userId: '', status: '', activityLogs: []),
  );

  if (currentUserBuyer.activityLogs.isEmpty) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: const Text("No activity logs available."),
      ),
    );
  }

  // Sort activity logs by timestamp in descending order
  List<ActivityLog> sortedLogs = List.from(currentUserBuyer.activityLogs);
  sortedLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

  return Card(
    elevation: 1,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: ExpansionTile(
      title: Text(
        'Activity Logs',
        style: TextStyle(
          color: theme.colorScheme.primary,
        ),
      ),
      children: sortedLogs.map<Widget>((log) {
        return buildActivityLogTile(log);
      }).toList(),
    ),
  );
}

Widget buildActivityLogTile(ActivityLog log) {
  String formattedDate = DateFormat('EEE d MMMM, h:mm a').format(log.timestamp);

  return Card(
    color: Colors.white,
    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 1),
    child: ListTile(
      leading: const Icon(Icons.event_note, color: Colors.blue),
      title: Text(
        log.description,
        style: const TextStyle(fontWeight: FontWeight.w100, fontSize: 14),
      ),
      subtitle: Text(
        formattedDate,
        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
      ),
    ),
  );
}
