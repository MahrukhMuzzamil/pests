import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/screens/lead_questions_form/lead_form_screen.dart';
// removed unused imports
import 'package:pests247/services/notification_services.dart';
import '../../../shared/controllers/app/app_controller.dart';
import '../../controllers/home/home_controller.dart';
import '../../controllers/user/user_controller.dart';
// removed unused imports
import 'components/user_profile_card.dart';
import 'components/widgets/build_images_container.dart';
import 'components/widgets/build_shimmer_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../service_provider/models/company_info/company_info_model.dart';
import '../../../service_provider/models/reviews/reviews_model.dart';
import '../../../service_provider/models/question_answers/question_answers_model.dart';
import 'components/company_profile_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/user_chat/chats_controller.dart';
import '../../screens/user_chats/chat_screen.dart';
import '../../../shared/models/user/user_model.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/animate_in.dart';
// Add these imports if you use geolocator or similar for current location
// removed unused imports

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
    _handleLocationPermissionAndFetch();
  }
  
  Future<void> _handleLocationPermissionAndFetch() async 
  {
    bool granted = await homeController.requestLocationPermission();
    if (granted) {
      // Permission granted, now fetch location and update Firestore
      await homeController.fetchAndStoreClientLocation(context);
    } else {
      // Permission denied, show snackbar or fallback happens inside fetchAndStoreClientLocation
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
          mainAxisSize: MainAxisSize.max,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 2),
                              Text(
                              (reviews != null && reviews.isNotEmpty)
                                  ? (reviews
                                          .map((e) => e.reviewUserRating)
                                          .reduce((a, b) => a + b) /
                                      reviews.length)
                                      .toStringAsFixed(1)
                                  : '0.0',
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${reviews != null ? reviews.length : 0})',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              if (companyInfo.isVerified)
                                const Padding(
                                  padding: EdgeInsets.only(left: 4.0),
                                  child: Icon(Icons.verified, color: Colors.blue, size: 16),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            (companyInfo.distanceFromUser != null)
                                ? 'Within ${companyInfo.distanceFromUser!.toStringAsFixed(1)} km of you'
                                : 'Location not available',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          //THIS BLOCK ONLY FOR DEBUGGING
                          if (companyInfo.rankScore != null)
                            Text(
                              'Rank Score: ${companyInfo.rankScore!.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                            ),//ENDBLOCK
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (companyInfo.gigDescription != null &&
                companyInfo.gigDescription!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  companyInfo.gigDescription!,
                      style: const TextStyle(fontSize: 12.5, color: Colors.black87),
                      maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 4),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size.fromHeight(36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                    child: const Text('View Profile', style: TextStyle(fontSize: 14, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size.fromHeight(36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () async {
                      // Fetch the full user document for the service provider
                      final docSnap = await FirebaseFirestore.instance.collection('users').doc(userId).get();
                      if (!docSnap.exists) return;
                      final userModel = UserModel.fromFirestore(docSnap);
                      final ChatController chatController = Get.put(ChatController());
                      await chatController.initializeChat(FirebaseAuth.instance.currentUser!.uid, userModel.uid);
                      // Send the auto message
                      await chatController.sendMessage(
                        'Hi, can you share details?',
                        userModel.uid,
                        context,
                        userController.userModel.value?.userName ?? '',
                        userModel.deviceToken ?? '',
                        null,
                      );
                      // Navigate to chat screen
                      Get.to(() => ChatScreen(userModel: userModel), transition: Transition.cupertino);
                    },
                    child: const Text('Request Quote', style: TextStyle(fontSize: 14, color: Colors.white)),
                  ),
                ),
              ],
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Get.to(() => LeadFormScreen(), transition: Transition.cupertino);
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Post a Job'),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (homeController.highestRatedUser != null)
                const SectionHeader(
                  title: 'Top Rated Provider',
                  subtitle: 'Best reviewed provider based on recent orders',
                ),
              GetBuilder<HomeController>(
                builder: (controller) {
                  return AnimateIn(
                    child: UserProfileCard(
                        highestRatedUser: controller.highestRatedUser),
                  );
                },
              ),
              const SectionHeader(
                title: 'Categories',
                subtitle: 'Select a service to get tailored quotes',
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
              const SectionHeader(
                title: 'Service Providers',
                subtitle: 'Ranked by reviews, proximity, and package',
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
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: MediaQuery.of(context).size.height < 700 ? 0.58 : 0.64,
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

                        return AnimateIn(
                          beginOffset: const Offset(0, 0.12),
                          beginScale: 0.96,
                          child: GestureDetector(
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
                          ),
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
