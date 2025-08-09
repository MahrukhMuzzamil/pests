import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../client/widgets/custom_snackbar.dart';
import '../data/keys.dart';
import '../shared/models/custom_order_model.dart';
import '../services/notification_services.dart';

class OrderManagementService extends GetxController {
  OrderManagementService._();
  static final OrderManagementService instance = OrderManagementService._();

  // Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus, {String? reason}) async {
    try {
      final orderRef = FirebaseFirestore.instance.collection('custom_orders').doc(orderId);
      
      Map<String, dynamic> updateData = {
        'status': newStatus,
      };

      // Add status-specific timestamps
      switch (newStatus) {
        case 'in_progress':
          updateData['startedDate'] = DateTime.now().toIso8601String();
          break;
        case 'completed':
          updateData['completedDate'] = DateTime.now().toIso8601String();
          break;
        case 'cancelled':
          updateData['cancelledDate'] = DateTime.now().toIso8601String();
          if (reason != null) {
            updateData['cancellationReason'] = reason;
          }
          break;
      }

      await orderRef.update(updateData);
      print('[OrderManagementService] Order status updated to: $newStatus');

      // Send notifications based on status change
      await _sendStatusChangeNotification(orderId, newStatus, reason);
    } catch (e) {
      print('[OrderManagementService] Error updating order status: $e');
      throw e;
    }
  }

  // Transfer provider earnings when order is completed
  Future<void> transferProviderEarnings(String orderId) async {
    try {
      final orderDoc = await FirebaseFirestore.instance
          .collection('custom_orders')
          .doc(orderId)
          .get();

      if (!orderDoc.exists) {
        throw Exception('Order not found');
      }

      final order = CustomOrder.fromFirestore(orderDoc);
      
      if (order.status != 'completed') {
        throw Exception('Order must be completed before transferring earnings');
      }

      if (order.providerStripeAccountId == null || order.providerStripeAccountId!.isEmpty) {
        throw Exception('Provider does not have a Stripe account configured');
      }

      // Transfer the earnings to provider's Stripe account
      await _transferToProvider(
        order.providerStripeAccountId!,
        order.providerEarnings,
        order,
      );

      // Update order with transfer details
      await FirebaseFirestore.instance
          .collection('custom_orders')
          .doc(orderId)
          .update({
        'transferStatus': 'completed',
        'transferDate': DateTime.now().toIso8601String(),
      });

      print('[OrderManagementService] Provider earnings transferred successfully');
    } catch (e) {
      print('[OrderManagementService] Error transferring provider earnings: $e');
      
      // Update order with transfer failure
      await FirebaseFirestore.instance
          .collection('custom_orders')
          .doc(orderId)
          .update({
        'transferStatus': 'failed',
        'transferError': e.toString(),
      });
      
      throw e;
    }
  }

  // Get orders for a user (client or provider)
  Future<List<CustomOrder>> getUserOrders(String userId, {String? status}) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('custom_orders')
          .where('clientId', isEqualTo: userId);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => CustomOrder.fromFirestore(doc)).toList();
    } catch (e) {
      print('[OrderManagementService] Error fetching user orders: $e');
      return [];
    }
  }

  // Get provider orders
  Future<List<CustomOrder>> getProviderOrders(String providerId, {String? status}) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('custom_orders')
          .where('providerId', isEqualTo: providerId);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => CustomOrder.fromFirestore(doc)).toList();
    } catch (e) {
      print('[OrderManagementService] Error fetching provider orders: $e');
      return [];
    }
  }

  // Get order details
  Future<CustomOrder?> getOrderDetails(String orderId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('custom_orders')
          .doc(orderId)
          .get();

      if (doc.exists) {
        return CustomOrder.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('[OrderManagementService] Error fetching order details: $e');
      return null;
    }
  }

  Future<void> _transferToProvider(String stripeAccountId, double amount, CustomOrder order) async {
    try {
      print('[OrderManagementService] Transferring \$${amount} to provider account: $stripeAccountId');
      
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        "amount": _calculateAmount(amount),
        "currency": "cad",
        "destination": stripeAccountId,
        "description": "Payment for completed order: ${order.description}",
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

      print('[OrderManagementService] Transfer response: ${response.data}');
      
      if (response.data != null) {
        // Update order with transfer details
        await FirebaseFirestore.instance
            .collection('custom_orders')
            .doc(order.id)
            .update({
          'transferId': response.data['id'],
        });
        
        print('[OrderManagementService] Transfer completed successfully.');
      }
    } catch (e) {
      print('[OrderManagementService] Error transferring to provider: $e');
      throw e;
    }
  }

  Future<void> _sendStatusChangeNotification(String orderId, String newStatus, String? reason) async {
    try {
      final order = await getOrderDetails(orderId);
      if (order == null) return;

      // Get user details
      final clientDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(order.clientId)
          .get();
      final providerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(order.providerId)
          .get();
      
      final clientData = clientDoc.data();
      final providerData = providerDoc.data();

      String clientMessage = '';
      String providerMessage = '';

      switch (newStatus) {
        case 'in_progress':
          clientMessage = 'Your order is now in progress!';
          providerMessage = 'Please start working on the order: ${order.description}';
          break;
        case 'completed':
          clientMessage = 'Your order has been completed!';
          providerMessage = 'Order completed! Earnings will be transferred to your account.';
          break;
        case 'cancelled':
          clientMessage = 'Your order has been cancelled.';
          providerMessage = 'Order cancelled by client.';
          if (reason != null) {
            clientMessage += ' Reason: $reason';
            providerMessage += ' Reason: $reason';
          }
          break;
      }

      // Send notification to client
      if (clientMessage.isNotEmpty) {
        await NotificationsServices.sendNotificationToDevice(
          order.clientId,
          Get.context!,
          'Pests 247',
          clientMessage,
        );
      }

      // Send notification to provider
      if (providerMessage.isNotEmpty) {
        await NotificationsServices.sendNotificationToDevice(
          order.providerId,
          Get.context!,
          'Pests 247',
          providerMessage,
        );
      }

      print('[OrderManagementService] Status change notifications sent successfully.');
    } catch (e) {
      print('[OrderManagementService] Error sending status change notifications: $e');
      // Don't throw error for notification failures
    }
  }

  String _calculateAmount(double amount) {
    final calculatedAmount = (amount * 100).toInt().toString();
    print('[OrderManagementService] Calculated amount (in smallest unit): $calculatedAmount');
    return calculatedAmount;
  }
} 