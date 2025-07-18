import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../service_provider/models/buyer/buyer_model.dart';


class LeadModel {
  String propertyType;
  List<String> pests;
  int credits;
  String status;
  String sightingsFrequency;
  List<String> services;
  String hiringDecision;
  String location;
  String additionalDetails;
  String email;
  String name;
  String userId;
  String leadId;
  DateTime submittedAt;
  List<Buyer> buyers;

  LeadModel({
    required this.additionalDetails,
    required this.leadId,
    required this.credits,
    required this.status,
    required this.propertyType,
    required this.pests,
    required this.sightingsFrequency,
    required this.services,
    required this.hiringDecision,
    required this.location,
    required this.email,
    required this.name,
    required this.userId,
    required this.submittedAt,
    required this.buyers,
  });

  Map<String, dynamic> toMap() {
    return {
      'propertyType': propertyType,
      'pests': pests,
      'sightingsFrequency': sightingsFrequency,
      'services': services,
      'hiringDecision': hiringDecision,
      'location': location,
      'additionalDetails': additionalDetails,
      'email': email,
      'name': name,
      'userId': userId,
      'submittedAt': submittedAt,
      'credits': credits,
      'leadId': leadId,
      'status': status,
      'buyers': buyers.map((buyer) => buyer.toMap()).toList(),
    };
  }

  factory LeadModel.fromMap(Map<String, dynamic> map) {
    return LeadModel(
      leadId: map['leadId'],
      additionalDetails: map['additionalDetails'],
      status: map['status'],
      propertyType: map['propertyType'],
      pests: List<String>.from(map['pests']),
      sightingsFrequency: map['sightingsFrequency'],
      services: List<String>.from(map['services']),
      hiringDecision: map['hiringDecision'],
      location: map['location'],
      email: map['email'],
      name: map['name'],
      userId: map['userId'],
      submittedAt: (map['submittedAt'] as Timestamp).toDate(),
      credits: map['credits'],
      buyers: (map['buyers'] as List)
          .map((buyerMap) => Buyer.fromMap(buyerMap))
          .toList(),
    );
  }
}
