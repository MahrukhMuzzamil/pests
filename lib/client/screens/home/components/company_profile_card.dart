import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../service_provider/models/company_info/company_info_model.dart';
import '../../../../service_provider/models/question_answers/question_answers_model.dart';
import '../../../../service_provider/models/reviews/reviews_model.dart';
import '../../../models/others/gig.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyProfileCard extends StatefulWidget {
  final String userId;
  final CompanyInfo? companyInfo;
  final List<Reviews>? reviews;
  final QuestionAnswerForm? questionAnswerForm;

  const CompanyProfileCard({
    super.key,
    required this.userId,
    required this.companyInfo,
    required this.reviews,
    required this.questionAnswerForm,
  });

  @override
  State<CompanyProfileCard> createState() => _CompanyProfileCardState();
}

class _CompanyProfileCardState extends State<CompanyProfileCard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Gig>> _gigsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this); // 6 tabs now
    _gigsFuture = fetchGigs(widget.userId);
  }

  Future<List<Gig>> fetchGigs(String userId) async {
    if (userId.isEmpty) return [];
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('gigs')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Gig.fromMap(doc.id, doc.data())).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double calculateAverageRating() {
    if (widget.reviews == null || widget.reviews!.isEmpty) return 0.0;
    List<double> ratings = widget.reviews!
        .map((review) => review.reviewUserRating.toDouble() ?? 0.0)
        .where((rating) => rating > 0)
        .toList();
    if (ratings.isEmpty) return 0.0;
    double total = ratings.reduce((a, b) => a + b).toDouble();
    return total / ratings.length;
  }

  @override
  Widget build(BuildContext context) {
    double averageRating = calculateAverageRating();
    final companyInfo = widget.companyInfo;
    final reviews = widget.reviews;
    final questionAnswerForm = widget.questionAnswerForm;
    final userId = widget.userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(companyInfo?.name ?? 'Profile'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'About'),
            Tab(text: 'Reviews'),
            Tab(text: 'Q&A'),
            Tab(text: 'Certifications'),
            Tab(text: 'Social'),
            Tab(text: 'Gigs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // About Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[200],
                    child: companyInfo?.logo != null && companyInfo!.logo!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              companyInfo!.logo!,
                              fit: BoxFit.cover,
                              width: 70,
                              height: 70,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, size: 40),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const SizedBox(
                                  width: 70,
                                  height: 70,
                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                );
                              },
                            ),
                          )
                        : const Icon(Icons.business, size: 40),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      companyInfo?.name ?? 'No business info set',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    if (companyInfo?.isVerified == true)
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.verified, color: Colors.greenAccent, size: 22),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  companyInfo?.description ?? 'No description available.',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    buildRatingStars(averageRating),
                    const SizedBox(width: 5),
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text('(${reviews?.length ?? 0} reviews)', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          // Reviews Tab
          reviews != null && reviews.isNotEmpty
              ? ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: reviews.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return ListTile(
                      leading: const Icon(Icons.person, color: Colors.blue),
                      title: Text(review.reviewUserName ?? 'Unknown'),
                      subtitle: Text(review.reviewUserText ?? 'No review'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 18),
                          Text('${review.reviewUserRating ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  },
                )
              : const Center(child: Text('No reviews available.', style: TextStyle(fontSize: 16, color: Colors.black54))),
          // Q&A Tab
          questionAnswerForm != null &&
                  ((questionAnswerForm.answer1 != null && questionAnswerForm.answer1!.isNotEmpty) ||
                   (questionAnswerForm.answer2 != null && questionAnswerForm.answer2!.isNotEmpty) ||
                   (questionAnswerForm.answer3 != null && questionAnswerForm.answer3!.isNotEmpty) ||
                   (questionAnswerForm.answer4 != null && questionAnswerForm.answer4!.isNotEmpty))
              ? ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (questionAnswerForm.question1 != null && questionAnswerForm.answer1 != null)
                      _buildQnA(context, questionAnswerForm.question1!, questionAnswerForm.answer1),
                    if (questionAnswerForm.question2 != null && questionAnswerForm.answer2 != null)
                      _buildQnA(context, questionAnswerForm.question2!, questionAnswerForm.answer2),
                    if (questionAnswerForm.question3 != null && questionAnswerForm.answer3 != null)
                      _buildQnA(context, questionAnswerForm.question3!, questionAnswerForm.answer3),
                    if (questionAnswerForm.question4 != null && questionAnswerForm.answer4 != null)
                      _buildQnA(context, questionAnswerForm.question4!, questionAnswerForm.answer4),
                  ],
                )
              : const Center(child: Text('No Q&A available.', style: TextStyle(fontSize: 16, color: Colors.black54))),
          // Certifications Tab
          companyInfo?.certifications != null && companyInfo!.certifications!.isNotEmpty
              ? ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text('Certifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ...companyInfo!.certifications!.map((url) => GestureDetector(
                          onTap: () => launchUrl(Uri.parse(url)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(url, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 13)),
                          ),
                        )),
                    if (companyInfo!.certificationStatus != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text('Status: ${companyInfo!.certificationStatus}', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      ),
                    if (companyInfo!.adminComment != null && companyInfo!.adminComment!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text('Admin: ${companyInfo!.adminComment}', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                      ),
                  ],
                )
              : const Center(child: Text('No certifications available.', style: TextStyle(fontSize: 16, color: Colors.black54))),
          // Social Tab
          (companyInfo?.facebookLink != null || companyInfo?.twitterLink != null || companyInfo?.website != null)
              ? ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (companyInfo?.facebookLink != null)
                      _buildSocialIcon('Facebook', FontAwesomeIcons.facebook, Colors.blue, companyInfo!.facebookLink!),
                    if (companyInfo?.twitterLink != null)
                      _buildSocialIcon('Twitter', FontAwesomeIcons.twitter, Colors.blue, companyInfo!.twitterLink!),
                    if (companyInfo?.website != null)
                      _buildSocialIcon('Website', FontAwesomeIcons.webflow, Colors.blue.shade700, companyInfo!.website!),
                  ],
                )
              : const Center(child: Text('No social links available.', style: TextStyle(fontSize: 16, color: Colors.black54))),
          // Gigs Tab
          FutureBuilder<List<Gig>>(
            future: _gigsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No gigs available.'));
              }
              final gigs = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: gigs.length,
                itemBuilder: (context, index) {
                  final gig = gigs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: gig.imageUrl.isNotEmpty
                          ? Image.network(gig.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                          : const Icon(Icons.image),
                      title: Text(gig.title),
                      subtitle: Text(
                        '\$${gig.price.toStringAsFixed(2)}\n${gig.description}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: true,
                      trailing: ElevatedButton(
                        onPressed: () {
                          // TODO: Show gig details or order page
                        },
                        child: const Text('View'),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQnA(BuildContext context, String question, String? answer) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Text(
            answer ?? 'No answer available.',
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(String title, IconData icon, Color color, String link) {
    return InkWell(
      onTap: () => launchUrl(Uri.parse(link)),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(title),
        ],
      ),
    );
  }

  Widget buildRatingStars(double averageRating) {
    int fullStars = averageRating.floor();
    int emptyStars = 5 - fullStars;
    return Row(
      children: List.generate(
        fullStars,
            (index) => const Icon(Icons.star, color: Colors.yellow, size: 16),
      ) +
          List.generate(
            emptyStars,
                (index) => const Icon(Icons.star_border, color: Colors.yellow, size: 16),
          ),
    );
  }
}
