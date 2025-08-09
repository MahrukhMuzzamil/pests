import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company_info/company_info_model.dart';
import 'profile/components/widgets/profile_image_card.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/animate_in.dart';
import '../../shared/widgets/empty_state.dart';

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
            return const Center(
              child: EmptyState(
                title: 'No businesses yet',
                description: 'Approved business listings will appear here. Check back soon.',
                lottieAsset: 'assets/lottie/empty.json',
              ),
            );
          }
          final businesses = snapshot.data!.docs.where((doc) => doc['companyInfo'] != null).toList();
          if (businesses.isEmpty) {
            return const Center(
              child: EmptyState(
                title: 'No businesses yet',
                description: 'Approved business listings will appear here. Check back soon.',
                lottieAsset: 'assets/lottie/empty.json',
              ),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Explore Local Businesses',
                  subtitle: 'Verified providers offering high-quality services near you',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= businesses.length) return const SizedBox();
                      final companyInfoMap = businesses[index]['companyInfo'] as Map<String, dynamic>;
                      final companyInfo = CompanyInfo.fromMap(companyInfoMap);
                      return AnimateIn(
                        child: BusinessGigCard(
                          businessName: companyInfo.name ?? '',
                          gigDescription: companyInfo.gigDescription ?? '',
                          gigImage: companyInfo.gigImage ?? '',
                          isVerified: companyInfo.isVerified,
                        ),
                      );
                    },
                    childCount: businesses.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 