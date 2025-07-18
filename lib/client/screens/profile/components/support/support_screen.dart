import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../controllers/profile/support_controller.dart';
import 'components/support_contact_card.dart';

class ClientSupportScreen extends StatelessWidget {
  const ClientSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ClientSupportController controller = Get.put(ClientSupportController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Support',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Need help? Contact our support team for assistance.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 30),
              // Email Section
              SupportContactCard(
                icon: Icons.email,
                title: 'Email Us',
                description:
                'Reach out via email, and our support team will get back to you shortly. Perfect for non-urgent inquiries.',
                contactInfo: controller.email.value,
                onPressed: () {
                  launch('mailto:${controller.email.value}');
                },
              ),

              const SizedBox(height: 30),

              // Phone Section
              SupportContactCard(
                icon: Icons.phone,
                title: 'Call Us',
                description:
                'Speak directly with our support team for immediate assistance. Ideal for urgent matters.',
                contactInfo: controller.phoneNumber.value,
                onPressed: () {
                  launch('tel:${controller.phoneNumber.value}');
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
