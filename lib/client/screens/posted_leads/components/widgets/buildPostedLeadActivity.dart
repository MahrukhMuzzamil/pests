import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../shared/models/lead_model/lead_model.dart';
import '../../../../../service_provider/models/activity_logs/activity_logs_model.dart';
import '../../../../../service_provider/models/buyer/buyer_model.dart';

Widget buildPostedLeadActivity(ThemeData theme, LeadModel lead) {
  List<Buyer> hiredBuyers = lead.buyers
      .where((buyer) => (buyer.status == 'hired' || buyer.status == 'completed'))
      .toList();

  print("Hired Buyers: $hiredBuyers");

  if (hiredBuyers.isEmpty) {
    print("No hired buyers found!");
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: const Text("No activity logs available."),
      ),
    );
  }

  List<ActivityLog> sortedLogs = [];

  for (var buyer in hiredBuyers) {
    print("Buyer: ${buyer.userId}, Activity Logs: ${buyer.activityLogs}");
    sortedLogs.addAll(buyer.activityLogs);
  }

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
        print("Building Activity Log Tile for: ${log.description}");
        return buildActivityLogTile(log);
      }).toList(),
    ),
  );
}

Widget buildActivityLogTile(ActivityLog log) {
  String formattedDate = DateFormat('EEE d MMMM, h:mm a').format(log.timestamp ?? DateTime.now());

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
