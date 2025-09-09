import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import '../client/widgets/custom_snackbar.dart';
import '../data/keys.dart';
import '../service_provider/models/credits/credit_history_model.dart';
import '../client/controllers/user/user_controller.dart';

class StripeService extends GetxController {
  StripeService._();

  static final StripeService instance = StripeService._();

  final RxBool isLoading = false.obs;

  Future<bool> makePayment(BuildContext context, int credits, double price) async {
    if (isLoading.value) return false;

    isLoading.value = true;

    try {
      print('[StripeService] Starting payment process...');
      String? paymentIntentSecret = await _createPaymentIntent(price, 'cad');
      if (paymentIntentSecret == null) {
        throw Exception('Failed to create payment intent');
      }
      print('[StripeService] Payment Intent created. Client Secret: $paymentIntentSecret');

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentSecret,
          merchantDisplayName: 'Pests 247',
        ),
      );
      print('[StripeService] Payment sheet initialized.');

      await Stripe.instance.presentPaymentSheet();
      print('[StripeService] Payment sheet presented successfully.');

      await processPayment(credits, context, price);
      return true;
    } catch (e) {
      print('[StripeService] Error during payment: $e');
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
      print('[StripeService] Payment process completed.');
    }
  }

  Future<void> processPayment(int credits, BuildContext context, double price) async {
    try {
      print('[StripeService] Presenting payment sheet...');
      final UserController userController = Get.find();
      await Stripe.instance.presentPaymentSheet();
      print('[StripeService] Payment sheet presented successfully.');

      await updateFirebaseCredits(
        userId: userController.userModel.value!.uid,
        credits: credits,
        price: price,
      );
      await userController.fetchUser();

      CustomSnackbar.showSnackBar(
        'Success',
        'Payment processed and credits updated.',
        const Icon(Ionicons.ticket),
        Theme.of(context).colorScheme.primary,
        context,
      );
    } catch (e) {
      print('[StripeService] Error presenting payment sheet: $e');
      CustomSnackbar.showSnackBar(
        'Error',
        'Payment failed. Please try again.',
        const Icon(Icons.error),
        Theme.of(context).colorScheme.error,
        context,
      );
    }
  }

  // One-off payment that does NOT change user credits. Use for visibility packages or other purchases.
  Future<bool> payForVisibilityPackage({
    required BuildContext context,
    required double price,
    String? description,
  }) async {
    if (isLoading.value) return false;
    isLoading.value = true;
    try {
      String? paymentIntentSecret = await _createPaymentIntent(price, 'cad');
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

      CustomSnackbar.showSnackBar(
        'Success',
        description ?? 'Payment successful.',
        const Icon(Ionicons.card),
        Theme.of(context).colorScheme.primary,
        context,
      );
      return true;
    } catch (e) {
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

  Future<void> updateFirebaseCredits({
    required String userId,
    required int credits,
    required double price,
    double? discount,
    String paymentMethod = 'Stripe',
    String? description,
  }) async {
    try {
      print('[StripeService] Updating Firebase credits for user: $userId...');
      final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

      final creditHistory = CreditHistoryModel(
        creditId: DateTime.now().millisecondsSinceEpoch,
        date: DateTime.now(),
        credits: credits,
        price: price,
        discount: discount,
        paymentMethod: paymentMethod,
        description: description,
      );

      final creditHistoryMap = creditHistory.toMap();

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        if (snapshot.exists) {
          transaction.update(userDoc, {
            'credits': FieldValue.increment(credits),
            'creditHistoryList': FieldValue.arrayUnion([creditHistoryMap]),
          });
        }
      });
      print('[StripeService] Firebase credits updated successfully.');
    } catch (e) {
      print('[StripeService] Failed to update Firebase: $e');
    }
  }

  Future<String?> _createPaymentIntent(double amount, String currency) async {
    try {
      print('[StripeService] Creating PaymentIntent for amount: $amount $currency...');
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
            "Authorization": "Bearer ${Keys.stripeSecretKey}", // Ensure live secret key is used
            "Content-Type": 'application/x-www-form-urlencoded',
          },
        ),
      );

      print('[StripeService] PaymentIntent response: ${response.data}');
      if (response.data != null) {
        return response.data['client_secret'];
      }
      print('[StripeService] No client_secret received.');
      return null;
    } catch (e) {
      print('[StripeService] Error creating PaymentIntent: $e');
      return null;
    }
  }

  String _calculateAmount(double amount) {
    final calculatedAmount = (amount * 100).toInt().toString();
    print('[StripeService] Calculated amount (in smallest unit): $calculatedAmount');
    return calculatedAmount;
  }
}
