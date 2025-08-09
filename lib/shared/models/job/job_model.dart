import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String jobId;
  final String title;
  final String description;
  final String locationText; // e.g., postal code, city, state
  final double latitude;
  final double longitude;
  final String postedByUserId;
  final DateTime createdAt;
  final String status; // e.g., open, closed

  JobModel({
    required this.jobId,
    required this.title,
    required this.description,
    required this.locationText,
    required this.latitude,
    required this.longitude,
    required this.postedByUserId,
    required this.createdAt,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'title': title,
      'description': description,
      'locationText': locationText,
      'latitude': latitude,
      'longitude': longitude,
      'postedByUserId': postedByUserId,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      jobId: map['jobId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      locationText: map['locationText'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      postedByUserId: map['postedByUserId'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: map['status'] as String,
    );
  }
}