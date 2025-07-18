import '../activity_logs/activity_logs_model.dart';

class Buyer {
  String userId;
  String status;
  List<ActivityLog> activityLogs;
  List<Map<String, dynamic>> quotes;

  Buyer({
    required this.userId,
    required this.status,
    this.activityLogs = const [],
    this.quotes = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'status': status,
      'activityLogs': activityLogs.map((log) => log.toMap()).toList(),
      'quotes': quotes,
    };
  }

  factory Buyer.fromMap(Map<String, dynamic> map) {
    return Buyer(
      userId: map['userId'],
      status: map['status'],
      activityLogs: (map['activityLogs'] as List)
          .map((logMap) => ActivityLog.fromMap(logMap))
          .toList(),
      quotes: (map['quotes'] as List)
          .map((quoteMap) => quoteMap as Map<String, dynamic>)
          .toList(),
    );
  }
}
