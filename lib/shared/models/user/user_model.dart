import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pests247/service_provider/models/company_info/company_info_model.dart';
import 'package:pests247/service_provider/models/question_answers/question_answers_model.dart';

import '../../../service_provider/models/credits/credit_history_model.dart';
import '../../../service_provider/models/reviews/reviews_model.dart';

class UserModel {
  final String accountType;
  final String uid;
  final String userName;
  final String email;
  final String country;
  final String phone;
  String? profilePicUrl;
  String? cardExpiry;
  String? cardNumber;
  final DateTime lastSeen;
  final String? deviceToken;

  String? emailTemplate;
  String? smsTemplate;
  num credits;
  num? completedServices;
  List<Reviews>? reviews;
  CompanyInfo? companyInfo;
  QuestionAnswerForm? questionAnswerForm;
  List<Map<String, dynamic>>? leadLocations;

  List<CreditHistoryModel>? creditHistoryList;

  UserModel({
    this.cardExpiry,
    this.cardNumber,
    required this.leadLocations,
    required this.credits,
    required this.accountType,
    required this.uid,
    required this.userName,
    required this.email,
    this.deviceToken,
    this.profilePicUrl,
    this.reviews,
    this.companyInfo,
    this.questionAnswerForm,
    this.completedServices,
    required this.country,
    required this.phone,
    required this.lastSeen,
    this.emailTemplate,
    this.smsTemplate,
    this.creditHistoryList,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'leadLocations': leadLocations,
      'userName': userName,
      'credits': credits,
      'accountType': accountType,
      'email': email,
      'deviceToken': deviceToken,
      'profilePicUrl': profilePicUrl,
      'country': country,
      'phone': phone,
      'reviews': reviews?.map((review) => review.toMap()).toList(),
      'companyInfo': companyInfo?.toMap(),
      'questionAnswerForm': questionAnswerForm?.toMap(),
      'completedServices': completedServices,
      'lastSeen': lastSeen.toIso8601String(),
      'emailTemplate': emailTemplate,
      'smsTemplate': smsTemplate,
      'cardExpiry': cardExpiry,
      'cardNumber': cardNumber,
      'creditHistoryList': creditHistoryList?.map((credit) => credit.toMap()).toList(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      accountType: json['accountType'] ?? '',
      cardExpiry: json['cardExpiry'] ?? '',
      cardNumber: json['cardNumber'] ?? '',
      uid: json['uid'] ?? '',
      leadLocations: (json['leadLocations'] as List<dynamic>?)
          ?.map((item) => Map<String, dynamic>.from(item))
          .toList() ??
          [],
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      deviceToken: json['deviceToken'],
      profilePicUrl: json['profilePicUrl'],
      country: json['country'] ?? '',
      phone: json['phone'] ?? '',
      credits: json['credits'] ?? 0,
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((item) => Reviews.fromMap(item))
          .toList(),
      companyInfo: json['companyInfo'] != null
          ? CompanyInfo.fromMap(json['companyInfo'])
          : null,
      questionAnswerForm: json['questionAnswerForm'] != null
          ? QuestionAnswerForm.fromMap(json['questionAnswerForm'])
          : null,
      completedServices: json['completedServices'] ?? 0,
      lastSeen: (json['lastSeen'] is Timestamp)
          ? (json['lastSeen'] as Timestamp).toDate()
          : DateTime.parse(json['lastSeen']),
      emailTemplate: json['emailTemplate'],
      smsTemplate: json['smsTemplate'],
      creditHistoryList: (json['creditHistoryList'] as List<dynamic>?)
          ?.map((item) => CreditHistoryModel.fromMap(item))
          .toList(),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }
}
