import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pests247/services/stripe_service.dart';
import '../../../../client/widgets/custom_button.dart';

class CreditDetailsController extends GetxController {
  final InAppPurchase _iap = InAppPurchase.instance;
  var available = false.obs;
  var products = <ProductDetails>[].obs;
  var isLoading = false.obs;
  late String productId;
  final String credits;
  final double price;
  final String? description;

  CreditDetailsController({required this.credits, required this.price, this.description});

  @override
  void onInit() {
    super.onInit();
    productId = 'credits_$credits';
    if (Platform.isIOS) {
      _initializeIAP();
      _iap.purchaseStream.listen(_handlePurchaseUpdates);
    }
  }


  Future<void> _initializeIAP() async {
    available.value = await _iap.isAvailable();
    if (available.value) {
      _getProductDetails();
    }
  }

  Future<void> _getProductDetails() async {
    try {
      final response = await _iap.queryProductDetails({productId});
      if (response.notFoundIDs.isNotEmpty) {
        print('Error: Product not found - ${response.notFoundIDs}');
      } else {
        products.assignAll(response.productDetails);
        print('Products fetched successfully: ${products.map((p) => p.id).toList()}');
      }
    } catch (e) {
      print('Error fetching product: $e');
    }
  }


  void buyProduct(BuildContext context,int? creditsForAndroidPurchase,double? priceForAndroidPurchase) async {
    isLoading.value = true;

    if (Platform.isIOS) {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: products.first);
      try {
        await _iap.buyConsumable(purchaseParam: purchaseParam);
      } catch (e) {
        print('Error purchasing product on iOS: $e');
      } finally {
        isLoading.value = false;
      }
    } else if (Platform.isAndroid) {
      try {
        await StripeService.instance.makePayment(context, creditsForAndroidPurchase!, priceForAndroidPurchase!);
      } catch (e) {
        print('Error purchasing product on Android: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }


  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        try {
          await StripeService.instance.updateFirebaseCredits(
            userId: FirebaseAuth.instance.currentUser!.uid,
            credits: int.parse(credits),
            price: price,
          );
          print("Credits updated successfully");
        } catch (e) {
          print('Error updating Firebase credits: $e');
        }
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }
}