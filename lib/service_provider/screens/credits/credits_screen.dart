import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../client/widgets/custom_button.dart';
import '../../controllers/credits/credits_controller.dart';
import 'components/credit_details_screen.dart';
import 'credit_history_screen.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CreditsController controller = Get.put(CreditsController());

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'History',
            icon: const Icon(Icons.history),
            onPressed: () {
              Get.to(() => const CreditHistoryScreen());
            },
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ListView.builder(
            itemCount: 6,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          );
        }

        if (controller.creditPackages.isEmpty) {
          return const Center(
            child: Text(
              'No credit packages available.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slider Component
            if(Platform.isAndroid )Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withOpacity(.2)),
              ),
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Credits',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary.withOpacity(.8),
                      fontSize: 16,
                    ),
                  ),
                  Obx(() {
                    final selectedCredits = controller.selectedCredits.value;
                    final price = selectedCredits * 2.47;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Slider(
                          value: selectedCredits.toDouble(),
                          min: 5,
                          max: 400,
                          divisions: 399,
                          label: '$selectedCredits Credits',
                          onChanged: (value) {
                            controller.selectedCredits.value = value.toInt();
                          },
                        ),
                        Text(
                          '$selectedCredits Credits = \$${price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          height: 40,
                          textStyle: const TextStyle(color: Colors.white),
                          text: 'Buy Credit',
                          onPressed: () {
                            print(selectedCredits);
                            print(price);
                            Get.to(() => CreditDetailsScreen(
                              credits: selectedCredits.toString(),
                              price: double.parse(price.toStringAsFixed(2)),
                            ));
                          },
                          isLoading: false,
                          tag: '',
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            // Existing Credit Packages
            Expanded(
              child: ListView.builder(
                itemCount: controller.creditPackages.length,
                itemBuilder: (context, index) {
                  final package = controller.creditPackages[index];
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => CreditDetailsScreen(
                        credits: package.credits.toString(),
                        price: package.price,
                        description: package.description,
                      ));
                    },
                    child: Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: const Text(
                            'C',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          '${package.credits} Credits',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          package.description ?? 'No description available',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        trailing: Text(
                          '\$${package.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
