import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../client/controllers/user/user_controller.dart';
import '../../../../models/reviews/reviews_model.dart';
import 'components/user_review_card.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final List<Reviews>? reviews = userController.userModel.value!.reviews;

    if (reviews == null || reviews.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Reviews & Ratings',style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        body: const Center(
          child: Text('No Reviews'),
        ),
      );
    }

    double averageRating = 0.0;
    for (var review in reviews) {
      averageRating += review.reviewUserRating ?? 0.0;
    }
    averageRating /= reviews.length;

    List<int> ratingCounts = [0, 0, 0, 0, 0];
    for (var review in reviews) {
      int rating = (review.reviewUserRating ?? 0).toInt();
      if (rating >= 1 && rating <= 5) {
        ratingCounts[rating - 1]++;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews & Ratings',style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Descriptive text
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  textAlign: TextAlign.justify,
                  'Want to know how others feel about the service they received? Browse through client reviews, see their ratings, and read their honest feedback.',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              // Row with average rating and total reviews
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 50, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            if (index < averageRating.floor()) {
                              return Icon(
                                Icons.star,
                                color: Colors.blue[700],
                                size: 20,
                              );
                            } else if (index < averageRating &&
                                index + 1 > averageRating) {
                              return Icon(
                                Icons.star_half,
                                color: Colors.blue[700],
                                size: 20,
                              );
                            } else {
                              return Icon(
                                Icons.star_border,
                                color: Colors.blue[700],
                                size: 20,
                              );
                            }
                          }),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Total Reviews: ${reviews.length}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(5, (index) {
                        double percentage =
                            (ratingCounts[4 - index] / reviews.length) * 100;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, right: 5),
                          child: Row(
                            children: [
                              Text(
                                '${5 - index}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.grey[300],
                                  ),
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    borderRadius: BorderRadius.circular(30),
                                    backgroundColor: Colors.grey[300],
                                    color: Colors.blue[700],
                                    minHeight: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Reviews list with stars and comments
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  if (index >= reviews.length) return const SizedBox();
                  var review = reviews[index];
                  int rating = review.reviewUserRating?.toInt() ?? 0;
                  return UserReviewCard(review: review, rating: rating);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
