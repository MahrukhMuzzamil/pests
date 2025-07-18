import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pests247/services/stripe_service.dart';
import '../../../../client/widgets/custom_button.dart';
import '../../../controllers/credits/credit_details_controller.dart';


class CreditDetailsScreen extends StatelessWidget {
  final String credits;
  final double price;
  final String? description;

  const CreditDetailsScreen({required this.credits, required this.price, this.description, super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreditDetailsController(credits: credits, price: price, description: description));
    final DateTime purchaseDate = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(.1)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: Get.width,
              padding: const EdgeInsets.all(20),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: const Text('C', style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$credits Credits',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          Text(
                            '\$$price',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (description != null && description!.isNotEmpty) ...[
                          const Text('Description:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Text(description!, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                          const SizedBox(height: 16),
                        ],
                        const Text('Purchase Date:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text('${purchaseDate.toLocal()}'.split(' ')[0], style: const TextStyle(fontSize: 15, color: Colors.black87)),
                        const Spacer(),
                        Center(
                          child: Obx(() => CustomButton(
                            onPressed:(){
                              controller.buyProduct(context, int.parse(credits), price);
                            },
                            height: 40,
                            textStyle: const TextStyle(color: Colors.white),
                            text: 'Buy Credit',
                            isLoading: controller.isLoading.value,
                            tag: '',
                          )),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
