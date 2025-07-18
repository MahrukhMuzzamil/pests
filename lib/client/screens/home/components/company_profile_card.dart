import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../service_provider/models/company_info/company_info_model.dart';
import '../../../../service_provider/models/question_answers/question_answers_model.dart';
import '../../../../service_provider/models/reviews/reviews_model.dart';

class CompanyProfileCard extends StatelessWidget {
  final CompanyInfo? companyInfo;
  final List<Reviews>? reviews;
  final QuestionAnswerForm? questionAnswerForm;

  const CompanyProfileCard({
    super.key,
    required this.companyInfo,
    required this.reviews,
    required this.questionAnswerForm,
  });

  double calculateAverageRating() {
    if (reviews == null || reviews!.isEmpty) return 0.0;

    List<double> ratings = reviews!
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

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Card(
          color: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          margin: const EdgeInsets.only(left: 15, right: 15, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(1),
                      Colors.blueAccent.withOpacity(.6)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[200],
                          child: companyInfo?.logo != null &&
                              companyInfo!.logo!.isNotEmpty
                              ? ClipOval(
                            child: Image.network(
                              companyInfo!.logo!,
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            ),
                          )
                              : const Icon(
                            Icons.business,
                            size: 25,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                companyInfo?.name ?? 'No business info set',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (companyInfo?.isVerified == true)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Icon(Icons.verified, color: Colors.greenAccent, size: 22),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      companyInfo?.description ?? 'No description available.',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        buildRatingStars(averageRating),
                        const SizedBox(width: 5),
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Certifications Section
              if (companyInfo?.certifications != null && companyInfo!.certifications!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.file_present, color: Colors.blue, size: 18),
                          const SizedBox(width: 6),
                          Text('Certifications', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black.withOpacity(.5))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ...companyInfo!.certifications!.map((url) => GestureDetector(
                        onTap: () => launchUrl(Uri.parse(url)),
                        child: Text(url, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 13)),
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
                  ),
                ),
              // Recent Reviews Section
              const SizedBox(height: 10),
              reviews != null && reviews!.isNotEmpty
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Recent Reviews',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(.3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CarouselSlider.builder(
                    itemCount: reviews!.length > 3 ? 3 : reviews!.length,
                    itemBuilder: (context, index, realIndex) {
                      return Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reviews![index].reviewUserName ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Flexible(
                              child: Text(
                                reviews![index].reviewUserText ?? 'No review',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.blue, size: 16),
                                const SizedBox(width: 5),
                                Text(
                                  '${reviews![index].reviewUserRating ?? 0}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    options: CarouselOptions(
                      height: 180,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 4),
                    ),
                  )
                ],
              )
                  : const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'No reviews available.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
              // Question and Answer Section
              const SizedBox(height: 10),
              questionAnswerForm != null &&
                  (questionAnswerForm!.answer1?.isNotEmpty ??
                      false || questionAnswerForm!.answer2!.isNotEmpty ??
                      false || questionAnswerForm!.answer3!.isNotEmpty ??
                      false || questionAnswerForm!.answer4!.isNotEmpty ??
                      false)
                  ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q&As',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black.withOpacity(.3),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildQuestionAnswer(context, questionAnswerForm),
                  ],
                ),
              )
                  : const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'No Q&A available.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
              // Website Section
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (companyInfo?.facebookLink != null ||
                        companyInfo?.twitterLink != null ||
                        companyInfo?.website != null)
                      Text(
                        'Social',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(.3),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        companyInfo?.facebookLink != null
                            ? _buildSocialIcon(
                            'Facebook',
                            FontAwesomeIcons.facebook,
                            Colors.blue,
                            companyInfo!.facebookLink!)
                            : Container(),
                        const SizedBox(height: 10),
                        companyInfo?.twitterLink != null
                            ? _buildSocialIcon(
                            'Twitter',
                            FontAwesomeIcons.twitter,
                            Colors.blue,
                            companyInfo!.twitterLink!)
                            : Container(),
                        const SizedBox(height: 10),
                        companyInfo?.website != null
                            ? _buildSocialIcon(
                            'Website',
                            FontAwesomeIcons.webflow,
                            Colors.blue.shade700,
                            companyInfo!.website!)
                            : Container(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionAnswer(
      BuildContext context, QuestionAnswerForm? questionAnswerForm) {
    return Column(
      children: [
        questionAnswerForm!.question1 != null &&
            questionAnswerForm.answer1 != null
            ? _buildQnA(context, '${questionAnswerForm.question1}',
            questionAnswerForm.answer1)
            : Container(),
        questionAnswerForm.question2 != null &&
            questionAnswerForm.answer2 != null
            ? _buildQnA(context, '${questionAnswerForm.question2}',
            questionAnswerForm.answer2)
            : Container(),
        questionAnswerForm.question3 != null &&
            questionAnswerForm.answer3 != null
            ? _buildQnA(context, '${questionAnswerForm.question3}',
            questionAnswerForm.answer3)
            : Container(),
        questionAnswerForm.question4 != null &&
            questionAnswerForm.answer4 != null
            ? _buildQnA(context, '${questionAnswerForm.question4}',
            questionAnswerForm.answer4)
            : Container(),
      ],
    );
  }

  Widget _buildQnA(BuildContext context, String question, String? answer) {
    return Container(
      width: Get.width,
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
