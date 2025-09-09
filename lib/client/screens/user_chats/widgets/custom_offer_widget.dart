import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/custom_offer_model.dart';
import '../../../../services/custom_offer_payment_service.dart';

class CustomOfferWidget extends StatelessWidget {
  final CustomOffer offer;
  final bool isClient;
  final String chatRoomId;
  
  const CustomOfferWidget({
    required this.offer, 
    required this.isClient, 
    required this.chatRoomId, 
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildOfferContent(),
            const SizedBox(height: 12),
            _buildPricingInfo(),
            const SizedBox(height: 8),
            _buildDeliveryTime(),
            if (offer.status == 'pending' && isClient) ...[
              const SizedBox(height: 16),
              _buildClientActions(context),
            ],
            if (offer.status == 'accepted' && isClient) ...[
              const SizedBox(height: 16),
              _buildPaymentButton(context),
            ],
            if (offer.status == 'paid') ...[
              const SizedBox(height: 12),
              _buildPaymentCompletedStatus(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.local_offer, color: Colors.blue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getOfferTitle(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              const Text(
                'Custom Offer',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(offer.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(offer.status).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        _getStatusText(offer.status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(offer.status),
        ),
      ),
    );
  }

  Widget _buildOfferContent() {
    String description = _getOfferDescription();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(
        description,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.4,
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildPricingInfo() {
    final commissionAmount = (offer.totalPrice * offer.commissionPercent) / 100;
    final providerAmount = offer.totalPrice - commissionAmount;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Price',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '\$${offer.totalPrice.toStringAsFixed(2)} CAD',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Platform Fee (${offer.commissionPercent.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                '-\$${commissionAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          if (!isClient) ...[
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'You earn',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                Text(
                  '\$${providerAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeliveryTime() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: Colors.blue[700], size: 16),
          const SizedBox(width: 8),
          Text(
            'Delivery: ${offer.timeline}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _respondToOffer(context, 'accepted'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text(
              'Accept Offer',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _respondToOffer(context, 'declined'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.cancel, size: 18),
            label: const Text(
              'Decline',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _processPayment(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        icon: const Icon(Icons.payment, size: 20),
        label: const Text(
          'Pay Now',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPaymentCompletedStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Completed',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (offer.paymentDate != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Paid on ${_formatDate(offer.paymentDate!)}',
                    style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getOfferTitle() {
    // Extract title from description (first line before \n\n)
    List<String> parts = offer.description.split('\n\n');
    if (parts.length > 1) {
      return parts[0].trim();
    }
    // Fallback: use first 30 characters
    return offer.description.length > 30 
        ? '${offer.description.substring(0, 30)}...'
        : offer.description;
  }

  String _getOfferDescription() {
    // Extract description (everything after first \n\n)
    List<String> parts = offer.description.split('\n\n');
    if (parts.length > 1) {
      return parts.sublist(1).join('\n\n').trim();
    }
    // If no title separator, return full description
    return offer.description;
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'declined':
        return 'Declined';
      case 'paid':
        return 'Paid';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
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
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _respondToOffer(BuildContext context, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('chat_room')
          .doc(chatRoomId)
          .collection('custom_offers')
          .doc(offer.id)
          .update({'status': status});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Offer ${status == 'accepted' ? 'accepted' : 'declined'} successfully!'),
          backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _processPayment(BuildContext context) async {
    try {
      final paymentService = CustomOfferPaymentService.instance;
      final success = await paymentService.processCustomOfferPayment(context, offer);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment processed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}