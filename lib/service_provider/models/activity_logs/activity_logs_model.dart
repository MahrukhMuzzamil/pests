class ActivityLog {
  String title;
  String description;
  DateTime timestamp;

  ActivityLog({
    required this.title,
    required this.description,
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      title: map['title'],
      description: map['description'],
    )..timestamp = DateTime.parse(map['timestamp']);
  }
}
