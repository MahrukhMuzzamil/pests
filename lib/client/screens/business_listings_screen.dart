import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'home/components/company_profile_card.dart';
import '../../service_provider/models/company_info/company_info_model.dart';
import '../../service_provider/models/reviews/reviews_model.dart';
import '../../service_provider/models/question_answers/question_answers_model.dart';

class ClientBusinessListingsScreen extends StatelessWidget {
  const ClientBusinessListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Service Providers'),
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
              final companyInfoMap = businesses[index]['companyInfo'] as Map<String, dynamic>;
              final companyInfo = CompanyInfo.fromMap(companyInfoMap);
              final reviews = (businesses[index]['reviews'] as List?)?.map((e) => Reviews.fromMap(e)).toList();
              final questionAnswerForm = businesses[index]['questionAnswerForm'] != null
                  ? QuestionAnswerForm.fromMap(businesses[index]['questionAnswerForm'])
                  : null;
              return GestureDetector(
                onTap: () {
                  Get.to(() => CompanyProfileCard(
                    companyInfo: companyInfo,
                    reviews: reviews,
                    questionAnswerForm: questionAnswerForm,
                  ), transition: Transition.cupertino);
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            companyInfo.gigImage != null && companyInfo.gigImage!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      companyInfo.gigImage!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const CircleAvatar(radius: 30, child: Icon(Icons.business)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                companyInfo.name ?? '',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (companyInfo.isVerified)
                              const Icon(Icons.verified, color: Colors.blue, size: 28),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (companyInfo.gigDescription != null && companyInfo.gigDescription!.isNotEmpty)
                          Text(
                            companyInfo.gigDescription!,
                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 