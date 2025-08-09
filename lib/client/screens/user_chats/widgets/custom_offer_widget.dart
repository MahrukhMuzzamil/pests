import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/custom_offer_model.dart';
import '../../../../services/custom_offer_payment_service.dart';

class CustomOfferWidget extends StatelessWidget {
  final CustomOffer offer;
  final bool isClient;
  final String chatRoomId;
  const CustomOfferWidget({required this.offer, required this.isClient, required this.chatRoomId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                const Icon(Icons.attach_money, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                const Text(
                  'Custom Offer',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(offer.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    offer.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(offer.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              offer.description,
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '\$${offer.totalPrice}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${offer.feeType})',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  '${offer.commissionPercent}% fee',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            if (offer.status == 'pending' && isClient)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Expanded(
                                              child: ElevatedButton(
                          onPressed: () => _respondToOffer(context, 'accepted'),
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
                          onPressed: () => _respondToOffer(context, 'declined'),
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
            if (offer.status == 'accepted' && isClient)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _processPayment(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      minimumSize: const Size(0, 28),
                      alignment: Alignment.center,
                    ),
                    child: const Text('Pay Now', style: TextStyle(fontSize: 11), textAlign: TextAlign.center),
                  ),
                ),
              ),
            if (offer.status == 'paid')
              Container(
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
                    const Text(
                      'Payment Completed',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'declined':
        return Colors.red;
      case 'paid':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _respondToOffer(BuildContext context, String status) async {
    await FirebaseFirestore.instance
      .collection('chat_room')
      .doc(chatRoomId)
      .collection('custom_offers')
      .doc(offer.id)
      .update({'status': status});
  }

  void _processPayment(BuildContext context) async {
    final paymentService = CustomOfferPaymentService.instance;
    final success = await paymentService.processCustomOfferPayment(context, offer);
    
    if (success) {
      // The payment service will update the offer status to 'paid'
      // No additional action needed here
    }
  }
} 