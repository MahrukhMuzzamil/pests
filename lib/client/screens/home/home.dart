import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/screens/lead_questions_form/lead_form_screen.dart';
import 'package:pests247/client/screens/on_board/start.dart';
import 'package:pests247/client/widgets/custom_snackbar.dart';
import 'package:pests247/services/notification_services.dart';
import '../../../shared/controllers/app/app_controller.dart';
import '../../controllers/home/home_controller.dart';
import '../../controllers/user/user_controller.dart';
import '../../widgets/custom_text_field.dart';
import 'components/user_profile_card.dart';
import 'components/widgets/build_images_container.dart';
import 'components/widgets/build_shimmer_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../service_provider/models/company_info/company_info_model.dart';
import '../../../service_provider/models/reviews/reviews_model.dart';
import '../../../service_provider/models/question_answers/question_answers_model.dart';
import 'components/company_profile_card.dart';

// Add these imports if you use geolocator or similar for current location
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeController homeController;
  late UserController userController;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    NotificationsServices.requestNotificationPermission();

    homeController = Get.put(HomeController(), permanent: true);
    userController = Get.put(UserController(), permanent: true);

    userController.fetchUser();
    _requestLocationPermission();
  }
  
  void _requestLocationPermission() async 
  {
    bool granted = await homeController.requestLocationPermission();
    if (!granted) {
      // Optionally show a dialog or snackbar informing the user about location permission.
      print('Location permission denied');
    }
  }

  void _checkLoginStatus() async {
    bool status = await AppController.checkLoginStatus();
    setState(() {
      isLoggedIn = status;
    });
  }

    Future<List<Map<String, dynamic>>> _rankBusinesses(List<QueryDocumentSnapshot> docs) async {
      try {
        final position = await homeController.getCurrentLocation();
        if (position == null) {
          print('Location permission denied or services off');
          return docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final companyInfo = CompanyInfo.fromMap(data['companyInfo']);
            return {
              'doc': doc,
              'companyInfo': companyInfo,
            };
          }).toList(); // Return unranked but still structured
        }

        // Map and pair companyInfo with original doc
        final companyMapList = docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final companyInfo = CompanyInfo.fromMap(data['companyInfo']);
          return {
            'doc': doc,
            'companyInfo': companyInfo,
          };
        }).toList();

        final companies = companyMapList.map((e) => e['companyInfo'] as CompanyInfo).toList();

        // Get ranked list
        final rankedCompanies = await homeController.getRankedBusinesses(
          companies,
          position.latitude,
          position.longitude,
        );

        List<Map<String, dynamic>> rankedDocs = [];

        for (var rankedCompany in rankedCompanies) {
          try {
            final match = companyMapList.firstWhere((e) {
              final originalCompany = e['companyInfo'] as CompanyInfo;
              return originalCompany.name == rankedCompany.name;
            });

            rankedDocs.add({
              'doc': match['doc'],
              'companyInfo': rankedCompany, // <- use updated one with rankScore
            });
          } catch (e) {
            // Skip if match fails
            continue;
          }
        }

        return rankedDocs;
      } catch (e) {
        print('Error in _rankBusinesses: $e');
        return [];
      }
    }


  Widget _buildCompanyCard(CompanyInfo companyInfo, List<Reviews>? reviews,
      QuestionAnswerForm? questionAnswerForm, String userId) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: companyInfo.gigImage != null && companyInfo.gigImage!.isNotEmpty
                      ? Image.network(
                          companyInfo.gigImage!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const CircleAvatar(radius: 24, child: Icon(Icons.business)),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              width: 48,
                              height: 48,
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            );
                          },
                        )
                      : const CircleAvatar(radius: 24, child: Icon(Icons.business)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyInfo.name ?? '',
                        style:
                            const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 2),
                          /*if (companyInfo.distanceFromUser != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Within ${companyInfo.distanceFromUser!.toStringAsFixed(1)} km of you',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Location not available',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),*/
                            Flexible(
                              child: (companyInfo.distanceFromUser != null)
                                  ? Text(
                                      'Within ${companyInfo.distanceFromUser!.toStringAsFixed(1)} km of you',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : const Text(
                                      'Location not available',
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                            ),
                            //THIS BLOCK ONLY FOR DEBUGGING
                            if (companyInfo.rankScore != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  'Rank Score: ${companyInfo.rankScore!.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                                ),
                              ),//ENDBLOCK
                          Text(
                            (reviews?.isNotEmpty ?? false)
                                ? (reviews!
                                        .map((e) => e.reviewUserRating ?? 0)
                                        .reduce((a, b) => a + b) /
                                    reviews.length)
                                    .toStringAsFixed(1)
                                : '0.0',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${reviews?.length ?? 0})',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          if (companyInfo.isVerified)
                            const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Icon(Icons.verified, color: Colors.blue, size: 16),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (companyInfo.gigDescription != null &&
                companyInfo.gigDescription!.isNotEmpty)
              Text(
                companyInfo.gigDescription!,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onPressed: () {
                  Get.to(() => CompanyProfileCard(
                        userId: userId,
                        companyInfo: companyInfo,
                        reviews: reviews,
                        questionAnswerForm: questionAnswerForm,
                      ),
                      transition: Transition.cupertino);
                },
                child:
                    const Text('View Profile', style: TextStyle(fontSize: 14, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => userController.isLoading.value ||
                userController.userModel.value == null
            ? const SizedBox()
            : Text(
                'Hi, ${userController.userModel.value?.userName ?? ''}',
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              )),
        elevation: 0,
        leadingWidth: 80,
        leading: GestureDetector(
          child: const CircleAvatar(
            child: Icon(
              CupertinoIcons.person,
              size: 33,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (userController.isLoading.value) {
          return buildShimmerEffect();
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Padding(
                padding:
                    const EdgeInsets.only(left: 20.0, right: 10.0, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (homeController.highestRatedUser != null)
                      Text(
                        'Top Rated',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(.5)),
                      ),
                  ],
                ),
              ),
              GetBuilder<HomeController>(
                builder: (controller) {
                  return UserProfileCard(
                      highestRatedUser: controller.highestRatedUser);
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 10.0, top: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categories',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(.5)),
                    ),
                  ],
                ),
              ),
              homeController.services.isEmpty
                  ? const Center(child: Text('No services found.'))
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      height: MediaQuery.of(context).size.height * .17,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                        ),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: homeController.services.length,
                        itemBuilder: (context, index) {
                          if (index >= homeController.services.length) {
                            return const SizedBox();
                          }
                          return imagesContainer(
                            homeController.services[index].imageURL,
                            homeController.services[index].name,
                            index,
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 10.0),
                child: Text(
                  'Service Providers',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(.5)),
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('accountType', isEqualTo: 'serviceProvider')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No businesses found.'));
                  }
                  final rawDocs = snapshot.data!.docs
                      .where((doc) =>
                          (doc.data() as Map<String, dynamic>)['companyInfo'] !=
                          null)
                      .toList();

                  if (rawDocs.isEmpty) {
                    return const Center(child: Text('No service providers available.'));
                  }

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: _rankBusinesses(rawDocs),
                  builder: (context, futureSnapshot) {
                    if (futureSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final rankedList = futureSnapshot.data ?? [];

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: rankedList.length,
                      itemBuilder: (context, index) {
                        final entry = rankedList[index];
                        final doc = entry['doc'] as QueryDocumentSnapshot;
                        final companyInfo = entry['companyInfo'] as CompanyInfo;

                        final data = doc.data() as Map<String, dynamic>;
                        final reviews = (data['reviews'] as List?)
                            ?.map((e) => Reviews.fromMap(e as Map<String, dynamic>))
                            .toList();
                        final questionAnswerForm = data['questionAnswerForm'] != null
                            ? QuestionAnswerForm.fromMap(data['questionAnswerForm'] as Map<String, dynamic>)
                            : null;
                        final userId = doc.id;

                        return GestureDetector(
                          onTap: () {
                            Get.to(
                              () => CompanyProfileCard(
                                userId: userId,
                                companyInfo: companyInfo,
                                reviews: reviews,
                                questionAnswerForm: questionAnswerForm,
                              ),
                              transition: Transition.cupertino,
                            );
                          },
                          child: _buildCompanyCard(companyInfo, reviews, questionAnswerForm, userId),
                        );
                      },
                    );
                  },
                );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
