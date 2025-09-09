import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../client/widgets/custom_snackbar.dart';
import '../data/keys.dart';
import '../shared/models/custom_offer_model.dart';
import '../shared/models/custom_order_model.dart';
import '../services/notification_services.dart';

class CustomOfferPaymentService extends GetxController {
  CustomOfferPaymentService._();
  static final CustomOfferPaymentService instance = CustomOfferPaymentService._();
  final RxBool isLoading = false.obs;

  Future<bool> processCustomOfferPayment(BuildContext context, CustomOffer offer) async {
    if (isLoading.value) return false;
    isLoading.value = true;

    try {
      print('[CustomOfferPaymentService] Starting custom offer payment process...');
      
      // Calculate commission and provider amount
      final commissionAmount = (offer.totalPrice * offer.commissionPercent) / 100;
      final providerAmount = offer.totalPrice - commissionAmount;
      
      print('[CustomOfferPaymentService] Total: \$${offer.totalPrice}, Commission: \$${commissionAmount}, Provider: \$${providerAmount}');

      // Create payment intent for the full amount
      String? paymentIntentSecret = await _createPaymentIntent(offer.totalPrice, 'cad');
      if (paymentIntentSecret == null) {
        throw Exception('Failed to create payment intent');
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentSecret,
          merchantDisplayName: 'Pests 247',
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      print('[CustomOfferPaymentService] Payment completed successfully.');

      // Update offer status and create order
      await _updateOfferAndCreateOrder(offer, commissionAmount, providerAmount);
      
      // Send notifications to both parties
      await _sendOrderNotifications(offer);
      
      CustomSnackbar.showSnackBar(
        'Payment Successful',
        'Your payment has been processed successfully.',
        const Icon(Icons.check_circle, color: Colors.green),
        Colors.green,
        context,
      );
      
      return true;
    } catch (e) {
      print('[CustomOfferPaymentService] Error during payment: $e');
      CustomSnackbar.showSnackBar(
        'Payment Failed',
        'An error occurred during payment. Please try again.',
        const Icon(Icons.error),
        Theme.of(context).colorScheme.error,
        context,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateOfferAndCreateOrder(CustomOffer offer, double commissionAmount, double providerAmount) async {
    try {
      final paymentData = {
        'status': 'paid',
        'paymentDate': DateTime.now().toIso8601String(),
        'commissionAmount': commissionAmount,
        'providerAmount': providerAmount,
        'totalPaid': offer.totalPrice,
        'paymentMethod': 'Stripe',
      };

      // Update the offer with payment details
      await FirebaseFirestore.instance
          .collection('chat_room')
          .doc(_getChatRoomId(offer.providerId, offer.clientId))
          .collection('custom_offers')
          .doc(offer.id)
          .update(paymentData);

      // Get provider's Stripe account ID
      final providerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(offer.providerId)
          .get();
      
      final providerData = providerDoc.data();
      final companyInfo = providerData?['companyInfo'] as Map<String, dynamic>?;
      final stripeAccountId = companyInfo?['stripeAccountId'] as String?;

      // Create CustomOrder record
      final orderId = const Uuid().v4();
      final customOrder = CustomOrder(
        id: orderId,
        offerId: offer.id,
        providerId: offer.providerId,
        clientId: offer.clientId,
        name: offer.name,
        description: offer.description,
        grossPrice: offer.totalPrice,
        commissionAmount: commissionAmount,
        providerEarnings: providerAmount,
        commissionPercent: offer.commissionPercent,
        status: 'in_progress', // Order status is now "In Progress"
        createdAt: DateTime.now(),
        paymentDate: DateTime.now(),
        startedDate: DateTime.now(), // Order starts immediately after payment
        paymentMethod: 'Stripe',
        providerStripeAccountId: stripeAccountId,
        transferStatus: 'pending', // Provider earnings held in pending state
      );

      // Store the order in Firestore
      await FirebaseFirestore.instance
          .collection('custom_orders')
          .doc(orderId)
          .set(customOrder.toMap());

      // Create a payment record for tracking
      await FirebaseFirestore.instance
          .collection('payments')
          .add({
        'orderId': orderId,
        'offerId': offer.id,
        'providerId': offer.providerId,
        'clientId': offer.clientId,
        'name' : offer.name,
        'totalAmount': offer.totalPrice,
        'commissionAmount': commissionAmount,
        'providerAmount': providerAmount,
        'commissionPercent': offer.commissionPercent,
        'paymentDate': DateTime.now().toIso8601String(),
        'status': 'completed',
        'paymentMethod': 'Stripe',
        'description': offer.description,
        'feeType': offer.feeType,
        'timeline': offer.timeline,
        'orderStatus': 'in_progress',
        'providerStripeAccountId': stripeAccountId,
        'transferStatus': 'pending',
      });

      print('[CustomOfferPaymentService] Order created and payment details updated successfully.');
    } catch (e) {
      print('[CustomOfferPaymentService] Error updating offer and creating order: $e');
      throw e;
    }
  }

  Future<void> _sendOrderNotifications(CustomOffer offer) async {
    try {
      // Get user details for notifications
      final clientDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(offer.clientId)
          .get();
      final providerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(offer.providerId)
          .get();
      
      final clientData = clientDoc.data();
      final providerData = providerDoc.data();
      
      final clientName = clientData?['userName'] ?? 'Client';
      final providerName = providerData?['userName'] ?? 'Provider';

      // Send notification to client
      await NotificationsServices.sendNotificationToDevice(
        offer.clientId,
        Get.context!,
        'Pests 247',
        'Your order has been confirmed and is now in progress!',
      );

      // Send notification to provider
      await NotificationsServices.sendNotificationToDevice(
        offer.providerId,
        Get.context!,
        'Pests 247',
        'New order received! Please start working on: ${offer.name}',
      );

      print('[CustomOfferPaymentService] Notifications sent successfully.');
    } catch (e) {
      print('[CustomOfferPaymentService] Error sending notifications: $e');
      // Don't throw error for notification failures
    }
  }

  Future<void> _transferToProvider(String stripeAccountId, double amount, CustomOffer offer) async {
    try {
      print('[CustomOfferPaymentService] Transferring \$${amount} to provider account: $stripeAccountId');
      
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        "amount": _calculateAmount(amount),
        "currency": "cad",
        "destination": stripeAccountId,
        "description": "Payment for: ${offer.name}",
      };

      var response = await dio.post(
        'https://api.stripe.com/v1/transfers',
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer ${Keys.stripeSecretKey}",
            "Content-Type": 'application/x-www-form-urlencoded',
          },
        ),
      );

      print('[CustomOfferPaymentService] Transfer response: ${response.data}');
      
      if (response.data != null) {
        // Update payment record with transfer details
        await FirebaseFirestore.instance
            .collection('payments')
            .where('offerId', isEqualTo: offer.id)
            .get()
            .then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            querySnapshot.docs.first.reference.update({
              'transferStatus': 'completed',
              'transferId': response.data['id'],
              'transferDate': DateTime.now().toIso8601String(),
            });
          }
        });
        
        print('[CustomOfferPaymentService] Transfer completed successfully.');
      }
    } catch (e) {
      print('[CustomOfferPaymentService] Error transferring to provider: $e');
      // Update payment record with transfer failure
      await FirebaseFirestore.instance
          .collection('payments')
          .where('offerId', isEqualTo: offer.id)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.first.reference.update({
            'transferStatus': 'failed',
            'transferError': e.toString(),
          });
        }
      });
    }
  }

  String _getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join("_");
  }

  Future<String?> _createPaymentIntent(double amount, String currency) async {
    try {
      print('[CustomOfferPaymentService] Creating PaymentIntent for amount: $amount $currency...');
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        "amount": _calculateAmount(amount),
        "currency": currency,
        "payment_method_types[]": "card",
      };

      var response = await dio.post(
        'https://api.stripe.com/v1/payment_intents',
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer ${Keys.stripeSecretKey}",
            "Content-Type": 'application/x-www-form-urlencoded',
          },
        ),
      );

      print('[CustomOfferPaymentService] PaymentIntent response: ${response.data}');
      if (response.data != null) {
        return response.data['client_secret'];
      }
      print('[CustomOfferPaymentService] No client_secret received.');
      return null;
    } catch (e) {
      print('[CustomOfferPaymentService] Error creating PaymentIntent: $e');
      return null;
    }
  }

  String _calculateAmount(double amount) {
    final calculatedAmount = (amount * 100).toInt().toString();
    print('[CustomOfferPaymentService] Calculated amount (in smallest unit): $calculatedAmount');
    return calculatedAmount;
  }
} 