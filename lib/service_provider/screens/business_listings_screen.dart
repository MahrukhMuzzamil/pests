import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/company_info/company_info_model.dart';
import 'profile/components/widgets/profile_image_card.dart';

class BusinessListingsScreen extends StatelessWidget {
  const BusinessListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Listings'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No businesses found.'));
          }
          final businesses = snapshot.data!.docs.where((doc) => doc['companyInfo'] != null).toList();
          if (businesses.isEmpty) {
            return const Center(child: Text('No businesses found.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              if (index >= businesses.length) return const SizedBox();
              final companyInfoMap = businesses[index]['companyInfo'] as Map<String, dynamic>;
              final companyInfo = CompanyInfo.fromMap(companyInfoMap);
              return BusinessGigCard(
                businessName: companyInfo.name ?? '',
                gigDescription: companyInfo.gigDescription ?? '',
                gigImage: companyInfo.gigImage ?? '',
                isVerified: companyInfo.isVerified,
              );
            },
          );
        },
      ),
    );
  }
} 