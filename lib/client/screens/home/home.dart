import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:pests247/client/screens/lead_questions_form/lead_form_screen.dart';
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
import '../../../shared/controllers/service_base_rate_controller.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/animate_in.dart';
import '../search/search_providers.dart';
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
  // Filter states
  bool showVerifiedOnly = false;
  double minRating = 0.0;
  bool nearMeOnly = false;
  String selectedCategory = 'All';

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

  Widget _buildHeroBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container
      (
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.primary.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(CupertinoIcons.sparkles, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Smarter matches, faster quotes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'We rank businesses using ratings, distance, and premium package so you see the best options first.',
                    style: TextStyle(color: Colors.black54, height: 1.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: const Text('All'),
            selected: true,
            onSelected: (_) => _showFilterSheet(),
            avatar: const Icon(Icons.filter_list, size: 16),
          ),
          const SizedBox(width: 8),
          if (showVerifiedOnly)
            FilterChip(
              label: const Text('Verified'),
              selected: true,
              onSelected: (_) => setState(() => showVerifiedOnly = false),
              deleteIcon: const Icon(Icons.close, size: 16),
            ),
          if (minRating > 0)
            FilterChip(
              label: Text('${minRating.toStringAsFixed(1)}+ stars'),
              selected: true,
              onSelected: (_) => setState(() => minRating = 0.0),
              deleteIcon: const Icon(Icons.close, size: 16),
            ),
          if (nearMeOnly)
            FilterChip(
              label: const Text('Near me'),
              selected: true,
              onSelected: (_) => setState(() => nearMeOnly = false),
              deleteIcon: const Icon(Icons.close, size: 16),
            ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              // Verified filter
              SwitchListTile(
                title: const Text('Verified providers only'),
                subtitle: const Text('Show only verified service providers'),
                value: showVerifiedOnly,
                onChanged: (value) => setModalState(() => showVerifiedOnly = value),
              ),
              
              // Rating filter
              const Text('Minimum Rating', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: minRating,
                      min: 0.0,
                      max: 5.0,
                      divisions: 10,
                      label: minRating.toStringAsFixed(1),
                      onChanged: (value) => setModalState(() => minRating = value),
                    ),
                  ),
                  Text('${minRating.toStringAsFixed(1)}+', style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              
              // Distance filter
              SwitchListTile(
                title: const Text('Near me only'),
                subtitle: const Text('Show providers within 50km'),
                value: nearMeOnly,
                onChanged: (value) => setModalState(() => nearMeOnly = value),
              ),
              
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          showVerifiedOnly = false;
                          minRating = 0.0;
                          nearMeOnly = false;
                        });
                      },
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
          
          // Debug logging
          print('Company: ${companyInfo.name}, Premium Package: ${companyInfo.premiumPackage}');
          
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


  Future<String?> _getGigImageUrl(String userId) async {
    try {
      final gigsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('gigs')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      
      if (gigsSnapshot.docs.isNotEmpty) {
        final gigData = gigsSnapshot.docs.first.data();
        return gigData['imageUrl'] as String?;
      }
      return null;
    } catch (e) {
      print('Error fetching gig image: $e');
      return null;
    }
  }

  Future<List<String>> _getCertificates(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final companyInfo = data['companyInfo'] as Map<String, dynamic>?;
        if (companyInfo != null) {
          final certifications = companyInfo['certifications'] as List<dynamic>?;
          if (certifications != null) {
            return certifications.map((e) => e as String).toList();
          }
        }
      }
      return [];
    } catch (e) {
      print('Error fetching certificates: $e');
      return [];
    }
  }

  Widget _buildCompanyListTile(CompanyInfo companyInfo, List<Reviews>? reviews,
      QuestionAnswerForm? questionAnswerForm, String userId) {
    final double rating = (reviews != null && reviews.isNotEmpty)
        ? (reviews.map((e) => e.reviewUserRating).reduce((a, b) => a + b) / reviews.length)
        : 0.0;

    // Debug logging
    print('Company: ${companyInfo.name}, Premium Package: ${companyInfo.premiumPackage}');

    return FutureBuilder<double?>(
      future: ServiceBaseRateController.getMinPriceForCategory(companyInfo.name ?? ''),
      builder: (context, snap) {
        final minPrice = snap.data;
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
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
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FutureBuilder<String?>(
                      future: _getGigImageUrl(userId),
                      builder: (context, snapshot) {
                        final String? gigImage = snapshot.data;
                        final String? logo = companyInfo.logo;
                        
                        if (gigImage != null && gigImage.isNotEmpty) {
                          return Image.network(
                            gigImage,
                            width: 96,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              if (logo != null && logo.isNotEmpty) {
                                return Image.network(logo, width: 96, height: 72, fit: BoxFit.cover);
                              }
                              return Image.asset('assets/images/service_provider.png', width: 96, height: 72, fit: BoxFit.cover);
                            },
                          );
                        }
                        if (logo != null && logo.isNotEmpty) {
                          return Image.network(logo, width: 96, height: 72, fit: BoxFit.cover);
                        }
                        return Image.asset('assets/images/service_provider.png', width: 96, height: 72, fit: BoxFit.cover);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(rating.toStringAsFixed(1),
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 4),
                            Text('(${reviews?.length ?? 0})',
                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            if (companyInfo.isVerified)
                              const Padding(
                                padding: EdgeInsets.only(left: 6.0),
                                child: Icon(Icons.verified, color: Colors.blue, size: 16),
                              ),
                            FutureBuilder<List<String>>(
                              future: _getCertificates(userId),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.only(left: 6.0),
                                    child: Icon(Icons.workspace_premium, color: Colors.amber, size: 16),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            const Spacer(),
                            if ((companyInfo.premiumPackage) > 0)
                              Flexible(
                                child: Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: companyInfo.premiumPackage == 3
                                        ? const Color(0xFFFFF7E6) // gold-ish bg
                                        : companyInfo.premiumPackage == 2
                                            ? const Color(0xFFF1F2F6) // silver-ish bg
                                            : companyInfo.premiumPackage == 1
                                                ? const Color(0xFFE8F0FF) // platinum-ish bg
                                                : const Color(0xFFF5F5F5), // default bg
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: companyInfo.premiumPackage == 3
                                          ? const Color(0xFFFFC107)
                                          : companyInfo.premiumPackage == 2
                                              ? const Color(0xFFB0BEC5)
                                              : companyInfo.premiumPackage == 1
                                                  ? const Color(0xFF90CAF9)
                                                  : const Color(0xFFE0E0E0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        companyInfo.premiumPackage == 3
                                            ? Icons.emoji_events // crown-like
                                            : companyInfo.premiumPackage == 2
                                                ? Icons.military_tech
                                                : companyInfo.premiumPackage == 1
                                                    ? Icons.workspace_premium
                                                    : Icons.star,
                                        size: 14,
                                        color: companyInfo.premiumPackage == 3
                                            ? const Color(0xFFFFA000)
                                            : companyInfo.premiumPackage == 2
                                                ? const Color(0xFF90A4AE)
                                                : companyInfo.premiumPackage == 1
                                                    ? const Color(0xFF42A5F5)
                                                    : const Color(0xFF757575),
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                child: Text(
                                          companyInfo.premiumPackage == 3
                                              ? 'Gold'
                                              : companyInfo.premiumPackage == 2
                                                  ? 'Silver'
                                                  : companyInfo.premiumPackage == 1
                                                      ? 'Platinum'
                                                      : 'Premium',
                                          style: TextStyle(
                                            color: companyInfo.premiumPackage == 3
                                                ? const Color(0xFFFF8F00)
                                                : companyInfo.premiumPackage == 2
                                                    ? const Color(0xFF78909C)
                                                    : companyInfo.premiumPackage == 1
                                                        ? const Color(0xFF1E88E5)
                                                        : const Color(0xFF424242),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          companyInfo.gigDescription ?? companyInfo.name ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                (companyInfo.distanceFromUser != null)
                                    ? 'Within ${companyInfo.distanceFromUser!.toStringAsFixed(1)} km'
                                    : 'Location not available',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (minPrice != null)
                              Text(
                                'From \$${minPrice.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_border),
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 6),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () async {
                          try {
                            final docSnap = await FirebaseFirestore.instance.collection('users').doc(userId).get();
                            if (!docSnap.exists) {
                              Get.snackbar('Error', 'Provider not found');
                              return;
                            }
                            final userModel = UserModel.fromFirestore(docSnap);
                            final ChatController chatController = Get.put(ChatController());
                            await chatController.initializeChat(FirebaseAuth.instance.currentUser!.uid, userModel.uid);
                            
                            // Try to send message, but don't fail if notification fails
                            try {
                              await chatController.sendMessage(
                                'Hi, I\'m interested in your services. Can you share more details?',
                                userModel.uid,
                                context,
                                userController.userModel.value?.userName ?? '',
                                userModel.deviceToken ?? '',
                                null,
                              );
                            } catch (e) {
                              print('Notification failed: $e');
                              // Continue to chat even if notification fails
                            }
                            
                            Get.to(() => ChatScreen(userModel: userModel), transition: Transition.cupertino);
                          } catch (e) {
                            print('Error opening chat: $e');
                            Get.snackbar('Error', 'Failed to open chat. Please try again.');
                          }
                        },
                        child: const Text('Request Quote', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            const CircleAvatar(child: Icon(CupertinoIcons.person)),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() => userController.isLoading.value || userController.userModel.value == null
                  ? const SizedBox()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hi, ${userController.userModel.value?.userName ?? ''}',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 2),
                        const Text('Get the most out of Pests247', style: TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    )),
            ),
            IconButton(onPressed: () { Get.to(() => const SearchProvidersScreen(), transition: Transition.cupertino); }, icon: const Icon(CupertinoIcons.search)),
            const SizedBox(width: 8),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (userController.isLoading.value) {
          return buildShimmerEffect();
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              _buildHeroBanner(context),
              const SizedBox(height: 8),
              _buildFilterChips(),
              const SizedBox(height: 8),
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
                title: 'Pest Services',
                subtitle: 'Select a service to get tailored quotes',
              ),
              homeController.services.isEmpty
                  ? const Center(child: Text('No services found.'))
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      height: 130,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          if (index >= homeController.services.length) return const SizedBox();
                          return SizedBox(
                            width: 220,
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => imagesContainer(
                            homeController.services[index].imageURL,
                            homeController.services[index].name,
                            index,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      const Icon(CupertinoIcons.photo_on_rectangle, size: 28),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          homeController.services[index].name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemCount: homeController.services.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
              const SizedBox(height: 20),
              const SectionHeader(
                title: 'Pest Service Providers',
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

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filterProviders(rankedList).length,
                      itemBuilder: (context, index) {
                        final entry = _filterProviders(rankedList)[index];
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
                          beginScale: 0.98,
                          child: _buildCompanyListTile(companyInfo, reviews, questionAnswerForm, userId),
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

  List<Map<String, dynamic>> _filterProviders(List<Map<String, dynamic>> providers) {
    return providers.where((entry) {
      final companyInfo = entry['companyInfo'] as CompanyInfo;
      final doc = entry['doc'] as QueryDocumentSnapshot;
      final data = doc.data() as Map<String, dynamic>;
      final reviews = (data['reviews'] as List?)
          ?.map((e) => Reviews.fromMap(e as Map<String, dynamic>))
          .toList();
      
      // Verified filter
      if (showVerifiedOnly && !companyInfo.isVerified) return false;
      
      // Rating filter
      if (minRating > 0) {
        final rating = (reviews != null && reviews.isNotEmpty)
            ? (reviews.map((e) => e.reviewUserRating).reduce((a, b) => a + b) / reviews.length)
            : 0.0;
        if (rating < minRating) return false;
      }
      
      // Distance filter
      if (nearMeOnly && (companyInfo.distanceFromUser == null || companyInfo.distanceFromUser! > 50)) {
        return false;
      }
      
      return true;
    }).toList();
  }
}
