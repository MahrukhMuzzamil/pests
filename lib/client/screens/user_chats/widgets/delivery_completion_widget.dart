import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../controllers/user_chat/chats_controller.dart';

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
    // Check for auto-acceptance when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndAutoAccept();
    });
    
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
        final DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
        final DateTime autoAcceptDate = createdAt.add(const Duration(days: 3));
        final bool isExpired = DateTime.now().isAfter(autoAcceptDate);
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text(
                      'Delivery Completed',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Service provider has marked the delivery as completed.'),
                const SizedBox(height: 4),
                Text(
                  'Auto-acceptance in: ${_formatTimeRemaining(autoAcceptDate)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                if (isClient && status == 'pending' && !isExpired)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _respondToDelivery(context, 'accepted'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Accept'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _respondToDelivery(context, 'declined'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Decline'),
                        ),
                      ),
                    ],
                  ),
                if (status == 'accepted')
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Delivery accepted. Payment will be released to provider in 14 days.',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (status == 'declined')
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cancel, color: Colors.red),
                        const SizedBox(width: 8),
                        const Text(
                          'Delivery declined by client.',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                if (isExpired && status == 'pending')
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          'Auto-accepted due to time expiration.',
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
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
    
    if (days > 0) {
      return '$days days, $hours hours';
    } else if (hours > 0) {
      return '$hours hours, $minutes minutes';
    } else {
      return '$minutes minutes';
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
          ? 'Delivery accepted. You will receive payment from platform in 14 days.'
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

      // If accepted, update custom order status
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
      final DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
      final DateTime autoAcceptDate = createdAt.add(const Duration(days: 3));
      
      // If status is still pending and 3 days have passed, auto-accept
      if (status == 'pending' && DateTime.now().isAfter(autoAcceptDate)) {
        _respondToDelivery(Get.context!, 'accepted');
      }
    } catch (e) {
      print('Error checking auto-acceptance: $e');
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
        await orderDoc.reference.update({
          'status': 'completed',
          'completedDate': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }
} 