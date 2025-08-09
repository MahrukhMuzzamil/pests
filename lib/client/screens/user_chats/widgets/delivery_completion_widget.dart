import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import '../../../controllers/user_chat/chats_controller.dart';
import '../../../../data/keys.dart';

class DeliveryCompletionWidget extends StatelessWidget {
  final String messageId;
  final String chatRoomId;
  final bool isClient;
  final String providerId;
  final String clientId;

  const DeliveryCompletionWidget({
    required this.messageId,
    required this.chatRoomId,
    required this.isClient,
    required this.providerId,
    required this.clientId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat_room')
          .doc(chatRoomId)
          .collection('delivery_completions')
          .doc(messageId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) return Container();
        
        final String status = data['status'] ?? 'pending';
        final bool autoAccepted = data['autoAccepted'] ?? false;
        final DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
        final DateTime autoAcceptDate = createdAt.add(const Duration(minutes: 2));
        final bool isExpired = DateTime.now().isAfter(autoAcceptDate);
        
        // Only check for auto-acceptance if status is still pending
        if (status == 'pending') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkAndAutoAccept();
          });
        }
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    const Text(
                      'Delivery Completed',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Service provider has marked the delivery as completed.',
                  style: const TextStyle(fontSize: 12),
                ),
                // Only show timer if status is pending
                if (status == 'pending') ...[
                const SizedBox(height: 4),
                Text(
                  'Auto acceptance in: ${_formatTimeRemaining(autoAcceptDate)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                ],
                if (isClient && status == 'pending' && !isExpired)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _respondToDelivery(context, 'accepted'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              minimumSize: const Size(0, 28),
                               alignment: Alignment.center,
                            ),
                             child: const Text('Accept', style: TextStyle(fontSize: 11), textAlign: TextAlign.center),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                                                     child: ElevatedButton(
                             onPressed: () => _respondToDelivery(context, 'declined'),
                             style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.red,
                               foregroundColor: Colors.white,
                               padding: const EdgeInsets.symmetric(vertical: 4),
                               minimumSize: const Size(0, 28),
                               alignment: Alignment.center,
                             ),
                             child: const Text('Decline', style: TextStyle(fontSize: 11), textAlign: TextAlign.center),
                           ),
                        ),
                      ],
                    ),
                  ),
                if (status == 'accepted')
                  FutureBuilder<String?>(
                    future: _getCurrentOrderId(),
                    builder: (context, orderIdSnapshot) {
                      if (!orderIdSnapshot.hasData || orderIdSnapshot.data == null) {
                        return Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 14),
                              const SizedBox(width: 4),
                              const Expanded(
                                child: Text(
                                  'Delivery accepted. Payment will be released to provider in 2 minutes.',
                                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('fund_holds')
                            .doc(orderIdSnapshot.data!)
                            .snapshots(),
                        builder: (context, fundSnapshot) {
                      String fundTimerText = 'Payment will be released to provider in 2 minutes.'; // Default text
                      
                      if (fundSnapshot.hasData && fundSnapshot.data!.exists) {
                        final fundData = fundSnapshot.data!.data() as Map<String, dynamic>;
                        final String fundStatus = fundData['status'] ?? 'pending';
                        
                        if (fundStatus == 'pending') {
                          final DateTime payoutDate = DateTime.parse(fundData['payoutDate']);
                          final Duration remaining = payoutDate.difference(DateTime.now());
                          
                          if (remaining.isNegative) {
                            fundTimerText = 'Payment processing...';
                          } else {
                            fundTimerText = 'Payment will be released in: ${_formatFundHoldTime(remaining)}';
                          }
                        } else if (fundStatus == 'completed') {
                          fundTimerText = 'Payment has been released to provider!';
                        } else if (fundStatus == 'failed') {
                          fundTimerText = 'Payment processing failed. Please contact support.';
                        }
                      }
                      
                      return Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 14),
                            const SizedBox(width: 4),
                                Expanded(
                              child: Text(
                                    'Delivery accepted. $fundTimerText',
                                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        // TESTING: Add test button for triggering payout
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: ElevatedButton(
                            onPressed: () => _testTriggerPayout(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              minimumSize: const Size(0, 24),
                            ),
                            child: const Text('TEST: Trigger Payout Now', style: TextStyle(fontSize: 10)),
                          ),
                        ),
                      ],
                    ),
                      );
                        },
                      );
                    },
                  ),
                if (status == 'declined')
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cancel, color: Colors.red, size: 14),
                        const SizedBox(width: 4),
                        const Text(
                          'Delivery declined by client.',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                if (autoAccepted && status == 'accepted')
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.orange, size: 14),
                        const SizedBox(width: 4),
                        const Text(
                          'Order was auto-accepted due to timeout.',
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTimeRemaining(DateTime autoAcceptDate) {
    final now = DateTime.now();
    final difference = autoAcceptDate.difference(now);
    
    if (difference.isNegative) {
      return 'Expired';
    }
    
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    if (days > 0) {
      return '$days days, $hours hours';
    } else if (hours > 0) {
      return '$hours hours, $minutes minutes';
    } else if (minutes > 0) {
      return '$minutes minutes, $seconds seconds';
    } else {
      return '$seconds seconds';
    }
  }

  String _formatFundHoldTime(Duration duration) {
    if (duration.isNegative) {
      return 'Processing...';
    }
    
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (days > 0) {
      return '$days days, $hours hours';
    } else if (hours > 0) {
      return '$hours hours, $minutes minutes';
    } else if (minutes > 0) {
      return '$minutes minutes, $seconds seconds';
    } else {
      return '$seconds seconds';
    }
  }

  Future<String?> _getCurrentOrderId() async {
    try {
      final ordersQuery = await FirebaseFirestore.instance
          .collection('custom_orders')
          .where('providerId', isEqualTo: providerId)
          .where('clientId', isEqualTo: clientId)
          .where('status', isEqualTo: 'completed')
          .get();

      if (ordersQuery.docs.isNotEmpty) {
        return ordersQuery.docs.first.id;
      }
      return null;
    } catch (e) {
      print('Error getting current order ID: $e');
      return null;
    }
  }

  // TESTING: Test button to trigger payout immediately
  void _testTriggerPayout(BuildContext context) async {
    try {
      // Find the custom order for this chat
      final ordersQuery = await FirebaseFirestore.instance
          .collection('custom_orders')
          .where('providerId', isEqualTo: providerId)
          .where('clientId', isEqualTo: clientId)
          .where('status', isEqualTo: 'completed')
          .get();

      if (ordersQuery.docs.isNotEmpty) {
        final orderId = ordersQuery.docs.first.id;
        print('[DeliveryCompletionWidget] TEST: Triggering payout for order: $orderId');
        await _processPayout(orderId);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('TEST: Payout triggered successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('TEST: No completed order found for payout'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('[DeliveryCompletionWidget] TEST: Error triggering payout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('TEST: Error triggering payout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _respondToDelivery(BuildContext context, String status) async {
    try {
      // Update delivery completion status
      await FirebaseFirestore.instance
          .collection('chat_room')
          .doc(chatRoomId)
          .collection('delivery_completions')
          .doc(messageId)
          .update({'status': status});

      // Send auto message to provider
      final message = status == 'accepted' 
          ? 'Delivery accepted. You will receive payment from platform in 2 minutes (testing mode).'
          : 'Delivery declined by client.';
      
      final chatController = Get.find<ChatController>();
      await chatController.sendMessage(
        message,
        providerId,
        context,
        'Client',
        '', // device token will be fetched by the service
        null,
      );

      // If accepted, update custom order status and start fund hold timer
      if (status == 'accepted') {
        _updateOrderStatus();
      }
    } catch (e) {
      print('Error responding to delivery: $e');
    }
  }

  void _checkAndAutoAccept() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('chat_room')
          .doc(chatRoomId)
          .collection('delivery_completions')
          .doc(messageId)
          .get();
      
      if (!doc.exists) return;
      
      final data = doc.data() as Map<String, dynamic>;
      final String status = data['status'] ?? 'pending';
      final bool autoAccepted = data['autoAccepted'] ?? false;
      final DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
      final DateTime autoAcceptDate = createdAt.add(const Duration(minutes: 2));

      // If status is still pending and 2 minutes have passed, auto-accept
      if (status == 'pending' && !autoAccepted && DateTime.now().isAfter(autoAcceptDate)) {
        _autoAcceptDelivery();
      }
    } catch (e) {
      print('Error checking auto-acceptance: $e');
    }
  }

  Future<void> _autoAcceptDelivery() async {
    try {
      // Update delivery completion status with auto-accepted flag
      await FirebaseFirestore.instance
          .collection('chat_room')
          .doc(chatRoomId)
          .collection('delivery_completions')
          .doc(messageId)
          .update({
        'status': 'accepted',
        'autoAccepted': true,
        'autoAcceptedAt': DateTime.now().toIso8601String(),
      });

      // Send auto message to provider with different text for auto-acceptance
      final message = 'Delivery auto-accepted due to timeout. You will receive payment from platform in 2 minutes (testing mode).';
      
      final chatController = Get.find<ChatController>();
      await chatController.sendMessage(
        message,
        providerId,
        Get.context!,
        'System',
        '', // device token will be fetched by the service
        null,
      );

      // Update custom order status and start fund hold timer
      _updateOrderStatus();
    } catch (e) {
      print('Error auto-accepting delivery: $e');
    }
  }

  void _updateOrderStatus() async {
    try {
      // Find the custom order for this chat
      final ordersQuery = await FirebaseFirestore.instance
          .collection('custom_orders')
          .where('providerId', isEqualTo: providerId)
          .where('clientId', isEqualTo: clientId)
          .where('status', isEqualTo: 'in_progress')
          .get();

      if (ordersQuery.docs.isNotEmpty) {
        final orderDoc = ordersQuery.docs.first;
        final orderId = orderDoc.id;
        
        // Update order status to completed
        await orderDoc.reference.update({
          'status': 'completed',
          'completedDate': DateTime.now().toIso8601String(),
        });

        // Start 14-day fund hold timer (TESTING: 1 minute for testing)
        await _startFundHoldTimer(orderId);
        
        print('[DeliveryCompletionWidget] Order status updated and fund hold timer started for order: $orderId');
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  // Start 14-day fund hold timer when order is completed
  Future<void> _startFundHoldTimer(String orderId) async {
    try {
      print('[DeliveryCompletionWidget] Starting 14-day fund hold timer for order: $orderId');
      
      // TESTING: Use 2 minutes instead of 14 days for testing
      final Duration holdDuration = const Duration(minutes: 2); // TESTING: Change to Duration(days: 14) for production
      
      final payoutDate = DateTime.now().add(holdDuration);
      
      // Create a fund hold record
      await FirebaseFirestore.instance
          .collection('fund_holds')
          .doc(orderId)
          .set({
        'orderId': orderId,
        'startDate': DateTime.now().toIso8601String(),
        'payoutDate': payoutDate.toIso8601String(),
        'status': 'pending',
        'holdDuration': holdDuration.inMinutes, // TESTING: Store in minutes for testing
        'isTestMode': true, // TESTING: Flag to indicate test mode
      });

      print('[DeliveryCompletionWidget] Fund hold timer started. Payout scheduled for: $payoutDate');
      
      // Schedule the payout
      _schedulePayout(orderId, payoutDate);
    } catch (e) {
      print('[DeliveryCompletionWidget] Error starting fund hold timer: $e');
    }
  }

  // Schedule payout using a simple timer (in production, use a proper job scheduler)
  void _schedulePayout(String orderId, DateTime payoutDate) {
    final now = DateTime.now();
    final delay = payoutDate.difference(now);
    
    if (delay.isNegative) {
      // If payout date has passed, process immediately
      _processPayout(orderId);
    } else {
      // Schedule payout
      Future.delayed(delay, () {
        _processPayout(orderId);
      });
    }
  }

  // Process the payout after the hold period
  Future<void> _processPayout(String orderId) async {
    try {
      print('[DeliveryCompletionWidget] Processing payout for order: $orderId');
      
      // Get the fund hold record
      final fundHoldDoc = await FirebaseFirestore.instance
          .collection('fund_holds')
          .doc(orderId)
          .get();
      
      if (!fundHoldDoc.exists) {
        print('[DeliveryCompletionWidget] Fund hold record not found for order: $orderId');
        return;
      }

      final fundHoldData = fundHoldDoc.data() as Map<String, dynamic>;
      final String status = fundHoldData['status'] ?? 'pending';
      
      if (status != 'pending') {
        print('[DeliveryCompletionWidget] Payout already processed for order: $orderId');
        return;
      }

      // Get the order details
      final orderDoc = await FirebaseFirestore.instance
          .collection('custom_orders')
          .doc(orderId)
          .get();

      if (!orderDoc.exists) {
        print('[DeliveryCompletionWidget] Order not found: $orderId');
        return;
      }

      final orderData = orderDoc.data() as Map<String, dynamic>;
      final String orderStatus = orderData['status'] ?? '';
      
      if (orderStatus != 'completed') {
        print('[DeliveryCompletionWidget] Order is not completed: $orderId');
        return;
      }

      // Perform Stripe transfer to provider
      final transferResult = await _transferToProvider(orderData);
      
      if (transferResult['success']) {
        // Update fund hold status to completed
        await FirebaseFirestore.instance
            .collection('fund_holds')
            .doc(orderId)
            .update({
          'status': 'completed',
          'payoutProcessedDate': DateTime.now().toIso8601String(),
          'transferId': transferResult['transferId'],
        });

        // Update order with final status
        await FirebaseFirestore.instance
            .collection('custom_orders')
            .doc(orderId)
            .update({
          'finalStatus': 'completed_with_payout',
          'payoutDate': DateTime.now().toIso8601String(),
          'transferStatus': 'completed',
          'transferId': transferResult['transferId'],
        });

        print('[DeliveryCompletionWidget] Payout processed successfully for order: $orderId');
        
        // Send notification to provider in chat
        await _sendPayoutNotification(orderData);
      } else {
        throw Exception('Stripe transfer failed: ${transferResult['error']}');
      }
      
    } catch (e) {
      print('[DeliveryCompletionWidget] Error processing payout: $e');
      
      // Update fund hold status to failed
      await FirebaseFirestore.instance
          .collection('fund_holds')
          .doc(orderId)
          .update({
        'status': 'failed',
        'error': e.toString(),
        'lastAttemptDate': DateTime.now().toIso8601String(),
      });
    }
  }

  // Transfer funds to provider's Stripe account
  Future<Map<String, dynamic>> _transferToProvider(Map<String, dynamic> orderData) async {
    try {
      final double providerEarnings = (orderData['providerEarnings'] as num).toDouble();
      final String? providerStripeAccountId = orderData['providerStripeAccountId'];
      final String orderId = orderData['id'] ?? '';
      
      print('[DeliveryCompletionWidget] Starting transfer to provider: $providerStripeAccountId');
      print('[DeliveryCompletionWidget] Amount: $providerEarnings CAD');
      
      if (providerStripeAccountId == null || providerStripeAccountId.isEmpty) {
        // Try to get from user document as fallback
        final providerId = orderData['providerId'];
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(providerId)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final companyInfo = userData['companyInfo'] as Map<String, dynamic>?;
          final stripeAccountId = companyInfo?['stripeAccountId'];
          
          if (stripeAccountId != null && stripeAccountId.isNotEmpty) {
            print('[DeliveryCompletionWidget] Found Stripe account ID from user document: $stripeAccountId');
            return await _createStripeTransfer(stripeAccountId, providerEarnings, orderId);
          }
        }
        
        throw Exception('Provider Stripe account ID not found');
      }
      
      return await _createStripeTransfer(providerStripeAccountId, providerEarnings, orderId);
      
    } catch (e) {
      print('[DeliveryCompletionWidget] Error in _transferToProvider: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Create Stripe transfer following the documentation
  Future<Map<String, dynamic>> _createStripeTransfer(String destinationAccountId, double amount, String orderId) async {
    try {
      print('[DeliveryCompletionWidget] Creating Stripe transfer...');
      print('[DeliveryCompletionWidget] Destination: $destinationAccountId');
      print('[DeliveryCompletionWidget] Amount: $amount CAD');
      
      final Dio dio = Dio();
      
      // Convert amount to smallest currency unit (cents for CAD)
      final amountInCents = (amount * 100).toInt();
      
      Map<String, dynamic> transferData = {
        'amount': amountInCents.toString(),
        'currency': 'cad',
        'destination': destinationAccountId,
        'transfer_group': 'ORDER_$orderId',
        'metadata': {
          'order_id': orderId,
          'transfer_type': 'provider_payout',
        },
      };
      
      print('[DeliveryCompletionWidget] Transfer data: $transferData');
      
      final response = await dio.post(
        'https://api.stripe.com/v1/transfers',
        data: transferData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Authorization': 'Bearer ${Keys.stripeSecretKey}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );
      
      print('[DeliveryCompletionWidget] Stripe transfer response: ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        final transferId = response.data['id'];
        print('[DeliveryCompletionWidget] Transfer successful. Transfer ID: $transferId');
        
        return {
          'success': true,
          'transferId': transferId,
        };
      } else {
        throw Exception('Unexpected response from Stripe: ${response.statusCode}');
      }
      
    } catch (e) {
      print('[DeliveryCompletionWidget] Error creating Stripe transfer: $e');
      
      if (e is DioException) {
        final response = e.response;
        if (response != null) {
          print('[DeliveryCompletionWidget] Stripe error response: ${response.data}');
          final errorData = response.data as Map<String, dynamic>?;
          final errorMessage = errorData?['error']?['message'] ?? 'Unknown Stripe error';
          return {
            'success': false,
            'error': 'Stripe API Error: $errorMessage',
          };
        }
      }
      
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Send payout notification to provider in chat
  Future<void> _sendPayoutNotification(Map<String, dynamic> orderData) async {
    try {
      final double providerEarnings = (orderData['providerEarnings'] as num).toDouble();
      final String providerId = orderData['providerId'];
      
      final message = '🎉 Payment of \$${providerEarnings} has been transferred to your Stripe account! Your order is now completed.';
      
      final chatController = Get.find<ChatController>();
      await chatController.sendMessage(
        message,
        providerId,
        Get.context!,
        'System',
        '', // device token will be fetched by the service
        null,
      );

      print('[DeliveryCompletionWidget] Payout notification sent to provider.');
    } catch (e) {
      print('[DeliveryCompletionWidget] Error sending payout notification: $e');
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 