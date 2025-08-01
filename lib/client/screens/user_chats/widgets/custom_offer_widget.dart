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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: ${offer.description}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Price: \$${offer.totalPrice} (${offer.feeType})'),
            Text('Timeline: ${offer.timeline}'),
            Text('Commission: ${offer.commissionPercent}%'),
            if (offer.status == 'pending' && isClient)
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _respondToOffer(context, 'accepted'),
                    child: const Text('Accept'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _respondToOffer(context, 'declined'),
                    child: const Text('Decline'),
                  ),
                ],
              ),
            if (offer.status == 'accepted' && isClient)
              ElevatedButton(
                onPressed: () => _processPayment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Pay Now'),
              ),
            if (offer.status == 'paid')
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
                    Text('Payment Completed', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            if (offer.status != 'pending' && offer.status != 'paid')
              Text('Status: ${offer.status}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
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