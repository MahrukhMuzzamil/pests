import 'package:cloud_firestore/cloud_firestore.dart';

class CreditHistoryModel {
  final int? creditId;
  final DateTime? date;
  final int? credits;
  final double? price;
  final double? discount;
  final String? paymentMethod;
  final String? description;

  CreditHistoryModel({
    this.creditId,
    this.date,
    this.credits,
    this.price,
    this.discount,
    this.paymentMethod,
    this.description,
  });

  factory CreditHistoryModel.fromMap(Map<String, dynamic> map) {
    return CreditHistoryModel(
      creditId: map['creditId'] as int?,
      date: map['date'] is Timestamp ? (map['date'] as Timestamp).toDate() : null,
      credits: _convertToInt(map['credits']),
      price: _convertToDouble(map['price']),
      discount: _convertToDouble(map['discount']),
      paymentMethod: map['paymentMethod'] as String?,
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'creditId': creditId,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'credits': credits,
      'price': price,
      'discount': discount,
      'paymentMethod': paymentMethod,
      'description': description,
    };
  }

  static int? _convertToInt(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is double) {
      return value.toInt();
    }
    return null;
  }

  static double? _convertToDouble(dynamic value) {
    if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    }
    return null;
  }
}
