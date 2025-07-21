import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/screens/home/components/company_profile_card.dart';
import '../../../../shared/models/user/user_model.dart';

class UserProfileCard extends StatelessWidget {
  const UserProfileCard({
    super.key,
    required this.highestRatedUser,
  });

  final UserModel? highestRatedUser;

  @override
  Widget build(BuildContext context) {
    if (highestRatedUser == null) {
      return const SizedBox();
    }

    final reviews = highestRatedUser!.reviews;
    int totalReviews = reviews?.length ?? 0;
    double averageRating = 0.0;

    if (totalReviews > 0) {
      double totalRating = reviews!.fold(0.0, (sum, review) {
        final rating = review.reviewUserRating as num? ?? 0;
        return sum + rating;
      });
      averageRating = totalRating / totalReviews;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GestureDetector(
        onTap: () {
          Get.to(
              () => CompanyProfileCard(
                    userId: highestRatedUser!.uid,
                    reviews: highestRatedUser!.reviews,
                    questionAnswerForm: highestRatedUser!.questionAnswerForm,
                    companyInfo: highestRatedUser!.companyInfo,
                  ),
              transition: Transition.cupertino);
        },
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(0, 4),
                blurRadius: 10.0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: highestRatedUser!.profilePicUrl != null  && highestRatedUser!.profilePicUrl!.isNotEmpty
                        ? Image.network(
                            highestRatedUser!.profilePicUrl!,
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                          )
                        : const CircleAvatar(
                            radius: 30,
                            child: Icon(
                              Icons.business_sharp,
                              size: 30,
                              color: Colors.black,
                            ),
                          ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          highestRatedUser?.companyInfo?.name ??
                              highestRatedUser?.userName ??
                              'Dummy Company',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            _buildRatingStars(averageRating),
                            const SizedBox(width: 4),
                            Text(
                              averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Completed Services: $totalReviews',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.4),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _buildRecentComment(highestRatedUser!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentComment(UserModel user) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100,
            offset: const Offset(0, 2),
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Comment',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            user.reviews!.isNotEmpty
                ? user.reviews!.first.reviewUserText!
                : 'No recent comment',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '- ${user.reviews!.isNotEmpty ? user.reviews!.first.reviewUserName! : 'Anonymous'}',
            style: const TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = rating - fullStars >= 0.5;

    return Row(
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(
            Icons.star,
            color: Colors.blue,
            size: 19,
          );
        } else if (index == fullStars && hasHalfStar) {
          return const Icon(
            Icons.star_half,
            color: Colors.blue,
            size: 19,
          );
        } else {
          return const Icon(
            Icons.star_border,
            color: Colors.blue,
            size: 19,
          );
        }
      }),
    );
  }
}
