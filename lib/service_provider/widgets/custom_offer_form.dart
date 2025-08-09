import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/custom_offer_model.dart'; // Adjust path as needed
import '../../../data/keys.dart'; // Use Keys.fetchCustomOfferCommission()
import 'package:firebase_auth/firebase_auth.dart';

class CustomOfferForm extends StatefulWidget {
  final String clientId;
  final String chatId; // You need to pass the chatId to know where to store the offer

  const CustomOfferForm({
    required this.clientId,
    required this.chatId,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomOfferForm> createState() => _CustomOfferFormState();
}

class _CustomOfferFormState extends State<CustomOfferForm> {
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _timelineController = TextEditingController();
  final _feeTypeController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _feeTypeController.text = 'one-time';
  }

  @override
  void dispose() {
    _descController.dispose();
    _priceController.dispose();
    _timelineController.dispose();
    _feeTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Send Custom Offer'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Total Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _timelineController,
              decoration: const InputDecoration(labelText: 'Timeline'),
            ),
            TextField(
              controller: _feeTypeController,
              decoration: const InputDecoration(labelText: 'Fee Type'),
            ),
          ],
        ),
      ),
      actions: [
        if (_loading) const CircularProgressIndicator(),
        if (!_loading)
          TextButton(
            onPressed: () async {
              setState(() => _loading = true);
              final commission = await Keys.fetchCustomOfferCommission();
              final providerId = FirebaseAuth.instance.currentUser!.uid;
              final offer = CustomOffer(
                id: const Uuid().v4(),
                providerId: providerId,
                clientId: widget.clientId,
                description: _descController.text,
                totalPrice: double.tryParse(_priceController.text) ?? 0,
                timeline: _timelineController.text,
                feeType: _feeTypeController.text.isEmpty
                    ? 'one-time'
                    : _feeTypeController.text,
                commissionPercent: commission,
                status: 'pending',
                createdAt: DateTime.now(),
              );
              // Save to Firestore (e.g., in chat_room/{chatId}/custom_offers/{offerId})
              await FirebaseFirestore.instance
                  .collection('chat_room')
                  .doc(widget.chatId)
                  .collection('custom_offers')
                  .doc(offer.id)
                  .set(offer.toMap());
              Navigator.pop(context);
            },
            child: const Text('Send Offer'),
          ),
      ],
    );
  }
}