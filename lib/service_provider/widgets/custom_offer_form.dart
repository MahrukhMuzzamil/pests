import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/custom_offer_model.dart';
import '../../../data/keys.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomOfferForm extends StatefulWidget {
  final String clientId;
  final String chatId;

  const CustomOfferForm({
    required this.clientId,
    required this.chatId,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomOfferForm> createState() => _CustomOfferFormState();
}

class _CustomOfferFormState extends State<CustomOfferForm> {
  final _formKey = GlobalKey<FormState>();
  final _offerNameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _deliveryDaysController = TextEditingController();
  bool _loading = false;
  double _commissionPercent = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCommissionRate();
  }

  Future<void> _loadCommissionRate() async {
    try {
      final commission = await Keys.fetchCustomOfferCommission();
      setState(() {
        _commissionPercent = commission;
      });
    } catch (e) {
      print('Error loading commission rate: $e');
      // Fallback to default commission rate
      setState(() {
        _commissionPercent = 10.0; // Default 10%
      });
    }
  }

  @override
  void dispose() {
    _offerNameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _deliveryDaysController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
    String? suffix,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixText: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPricingSummary() {
    double totalPrice = double.tryParse(_priceController.text) ?? 0.0;
    double commissionAmount = (totalPrice * _commissionPercent) / 100;
    double youEarn = totalPrice - commissionAmount;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pricing Breakdown',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Price:', style: TextStyle(fontSize: 13)),
              Text('\$${totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Platform Fee (${_commissionPercent.toStringAsFixed(1)}%):', 
                   style: const TextStyle(fontSize: 13, color: Colors.grey)),
              Text('-\$${commissionAmount.toStringAsFixed(2)}', 
                   style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          const Divider(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('You earn:', 
                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green)),
              Text('\$${youEarn.toStringAsFixed(2)}', 
                   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Create Custom Offer',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSectionTitle('Offer Name'),
                _buildTextField(
                  controller: _offerNameController,
                  label: 'Service Title',
                  hint: 'e.g., Pest Control Treatment',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an offer name';
                    }
                    return null;
                  },
                ),

                _buildSectionTitle('Description'),
                _buildTextField(
                  controller: _descController,
                  label: 'Service Description',
                  hint: 'Describe what you will provide in detail...',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    if (value.trim().length < 20) {
                      return 'Please provide a more detailed description';
                    }
                    return null;
                  },
                ),

                _buildSectionTitle('Single Payment'),
                _buildTextField(
                  controller: _priceController,
                  label: 'Total Price',
                  hint: '0.00',
                  suffix: 'CAD',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a price';
                    }
                    double? price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Please enter a valid price';
                    }
                    if (price < 10) {
                      return 'Minimum price is \$10.00';
                    }
                    return null;
                  },
                ),

                // Show pricing breakdown when price is entered
                if (_priceController.text.isNotEmpty && double.tryParse(_priceController.text) != null)
                  _buildPricingSummary(),

                _buildSectionTitle('Delivery Time'),
                _buildTextField(
                  controller: _deliveryDaysController,
                  label: 'Delivery Time',
                  hint: '1',
                  suffix: 'days',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter delivery time';
                    }
                    int? days = int.tryParse(value);
                    if (days == null || days <= 0) {
                      return 'Please enter a valid number of days';
                    }
                    if (days > 365) {
                      return 'Maximum delivery time is 365 days';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _loading ? null : _submitOffer,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: _loading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Send Offer'),
        ),
      ],
    );
  }

  Future<void> _submitOffer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    try {
      final providerId = FirebaseAuth.instance.currentUser!.uid;
      final deliveryDays = int.parse(_deliveryDaysController.text);
      
      final offer = CustomOffer(
        id: const Uuid().v4(),
        providerId: providerId,
        clientId: widget.clientId,
        name: _offerNameController.text.trim(), // Store name separately
        description: _descController.text.trim(), // Store description separately
        totalPrice: double.parse(_priceController.text),
        timeline: '$deliveryDays days', // Store as "X days" format
        feeType: 'one-time', // Since this is single payment
        commissionPercent: _commissionPercent,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('chat_room')
          .doc(widget.chatId)
          .collection('custom_offers')
          .doc(offer.id)
          .set(offer.toMap());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Custom offer sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error creating custom offer: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending offer: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}