import 'package:cloud_firestore/cloud_firestore.dart';

class JobPost {
  final String id;
  final String createdBy;
  final String title;
  final String description;
  final String postalCode;
  final String? city;
  final String? state;
  final double latitude;
  final double longitude;
  final List<String> services;
  final List<String> pests;
  final DateTime createdAt;

  JobPost({
    required this.id,
    required this.createdBy,
    required this.title,
    required this.description,
    required this.postalCode,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.services,
    required this.pests,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdBy': createdBy,
      'title': title,
      'description': description,
      'postalCode': postalCode,
      'city': city,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'services': services,
      'pests': pests,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory JobPost.fromMap(Map<String, dynamic> data) {
    return JobPost(
      id: data['id'] as String,
      createdBy: data['createdBy'] as String,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      postalCode: data['postalCode'] as String? ?? '',
      city: data['city'] as String?,
      state: data['state'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      services: (data['services'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      pests: (data['pests'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}


