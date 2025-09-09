import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pests247/client/controllers/home/home_controller.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';
import 'package:pests247/service_provider/screens/profile/components/reviews/reviews_screen.dart';
import 'package:pests247/service_provider/screens/profile/settings_view.dart';
import '../../../client/widgets/custom_icon_button.dart';
import '../../../client/widgets/custom_menu_card.dart';
import 'package:shimmer/shimmer.dart';
import 'components/about/user_info_screen.dart';
import 'components/widgets/profile_image_card.dart';
import 'package:pests247/service_provider/services/package_service.dart';
import 'package:pests247/shared/models/package/package.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' as material;
import 'package:pests247/services/stripe_service.dart';
import 'package:pests247/service_provider/screens/credits/credits_screen.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    UserController userController = Get.find();

    return Scaffold(
      backgroundColor: Colors.blue.withOpacity(1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          CustomIconButton(
            onTap: () {
              Get.to(() => const SettingsView(), transition: Transition.cupertino);
            },
            icon: Icons.settings,
            iconColor: Colors.white,
            color: Colors.white.withOpacity(0.15),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                margin: const EdgeInsets.only(top: 40),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 140,
                  ),
                  child: Column(
                  children: [
                    const SizedBox(height: 65),
                    Obx(() {
                      return userController.isLoading.value
                          ? _buildShimmerLoading()
                          : Text(
                        userController.userModel.value?.userName ?? 'User Name',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      );
                    }),
                    Obx(() {
                      return userController.isLoading.value
                          ? _buildShimmerLoading()
                          : Text(
                        userController.userModel.value?.accountType == 'serviceProvider'
                            ? 'Pest Service Provider'
                            : 'Account type not set',
                        style: const TextStyle(
                            fontWeight: FontWeight.w200, fontSize: 13),
                      );
                    }),
                    const SizedBox(height: 30),
                    // Show current visibility package
                    Obx(() {
                      final user = userController.userModel.value;
                      if (user == null || user.visibilityPackage == null) {
                        return const SizedBox();
                      }
                      final expiry = user.visibilityPackageExpiry is Timestamp
                          ? (user.visibilityPackageExpiry as Timestamp).toDate()
                          : user.visibilityPackageExpiry;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          color: Colors.green[50],
                          child: ListTile(
                            leading: const Icon(Icons.verified, color: Colors.green),
                            title: Text('Current Package: ${user.visibilityPackageName ?? user.visibilityPackage ?? ''}'),
                            subtitle: expiry != null
                                ? Text('Expires on: ${expiry.toString().split(' ')[0]}')
                                : null,
                          ),
                        ),
                      );
                    }),
                    // Visibility Packages Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Visibility Packages',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Activate Platinum, Gold, or Silver to boost your ranking.',
                            style: TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('visibilityPackages')
                                .orderBy('tier', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('No visibility packages available.'),
                                    const SizedBox(height: 8),
                                    OutlinedButton(
                                      onPressed: () {
                                        Get.to(
                                          () => const SettingsView(),
                                          transition: Transition.cupertino,
                                        );
                                      },
                                      child: const Text('Open Manage Visibility'),
                                    ),
                                  ],
                                );
                              }
                              final docs = snapshot.data!.docs;
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: docs.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final pkg = docs[index].data();
                                  final String name = pkg['name']?.toString() ?? '';
                                  final int tier = (pkg['tier'] as num?)?.toInt() ?? 0;
                                  final int duration = (pkg['durationDays'] as num?)?.toInt() ?? 30;
                                  final double price = (pkg['price'] as num?)?.toDouble() ?? 0.0;
                                  final String description = pkg['description']?.toString() ?? '';

                                  // Pick icon/color by name first (gold/silver/platinum), fallback to tier
                                  final lname = name.toLowerCase();
                                  IconData icon;
                                  Color color;
                                  if (lname.contains('gold')) {
                                    icon = Icons.emoji_events; // trophy
                                    color = const Color(0xFFFFD700); // Gold color
                                  } else if (lname.contains('silver')) {
                                    icon = Icons.military_tech; // medal
                                    color = const Color(0xFFC0C0C0); // Silver color
                                  } else if (lname.contains('platinum')) {
                                    icon = Icons.workspace_premium; // premium/crown-like
                                    color = const Color(0xFF1E88E5); // Blue color
                                  } else {
                                    switch (tier) {
                                      case 3:
                                        icon = Icons.emoji_events;
                                        color = const Color(0xFFFFA000);
                                        break;
                                      case 2:
                                        icon = Icons.military_tech;
                                        color = const Color(0xFF90A4AE);
                                        break;
                                      default:
                                        icon = Icons.workspace_premium;
                                        color = const Color(0xFF1E88E5);
                                    }
                                  }

                                  return material.Card(
                                    child: ListTile(
                                      leading: CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color)),
                                      title: Text('$name (Tier $tier)'),
                                      subtitle: Text('Duration: $duration days • Price: ${price.toStringAsFixed(2)}\n$description'),
                                      isThreeLine: description.isNotEmpty,
                                      trailing: ElevatedButton(
                                        onPressed: () async {
                                          final uid = FirebaseAuth.instance.currentUser?.uid;
                                          if (uid == null) return;
                                          final DateTime expiry = DateTime.now().add(Duration(days: duration));
                                          final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
                                          await FirebaseFirestore.instance.runTransaction((txn) async {
                                            final snap = await txn.get(userRef);
                                            if (!snap.exists) return;
                                            final data = snap.data() as Map<String, dynamic>;
                                            final Map<String, dynamic> newCompanyInfo = Map<String, dynamic>.from(data['companyInfo'] ?? {});
                                            newCompanyInfo['premiumPackage'] = tier;
                                            txn.update(userRef, {
                                              'companyInfo': newCompanyInfo,
                                              'visibilityPackage': docs[index].id,
                                              'visibilityPackageName': name,
                                              'visibilityPackageExpiry': Timestamp.fromDate(expiry),
                                            });
                                          });
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Activated $name (expires ${expiry.toLocal().toString().split(' ')[0]})')),
                                            );
                                          }
                                        },
                                        child: const Text('Activate'),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Packages Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Available Credit Bundles',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.to(() => const CreditsScreen());
                                },
                                child: const Text(
                                  'Manage Credits',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Buy credits to appear higher in search and unlock more leads.',
                            style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          StreamBuilder<List<Package>>(
                            stream: PackageService().getPackagesStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              final packages = snapshot.data ?? [];
                              if (packages.isEmpty) {
                                return const Text('No packages available.');
                              }
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: packages.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final pkg = packages[index];
                                  return material.Card(
                                    // Use material.Card to avoid conflict with Stripe's Card
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      leading: pkg.isPopular
                                          ? const Icon(Icons.star, color: Colors.orange)
                                          : const Icon(Icons.credit_card),
                                      title: Text('${pkg.credits} Credits'),
                                      subtitle: Text(pkg.description.isNotEmpty ? pkg.description : 'No description'),
                                      trailing: Text('\$${pkg.price.toStringAsFixed(2)}'),
                                      onTap: () async {
                                        final user = FirebaseAuth.instance.currentUser;
                                        if (user == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Please log in to purchase credits.')),
                                          );
                                          return;
                                        }
                                        try {
                                          await StripeService.instance.makePayment(context, pkg.credits, pkg.price);
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Payment failed or cancelled: $e')),
                                          );
                                        }
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CustomMenuCard(
                          isSelected: false,
                          icon: Icons.account_box_outlined,
                          onTap: () {
                            Get.to(() => const UserInfoScreen(),
                                transition: Transition.cupertino);
                          },
                          title: 'About',
                        ),
                        CustomMenuCard(
                          isSelected: false,
                          icon: Icons.reviews_outlined,
                          onTap: () {
                            Get.to(() => const ReviewsScreen(),
                                transition: Transition.cupertino);
                          },
                          title: 'Reviews',
                        ),
                        CustomMenuCard(
                          isSelected: false,
                          icon: FontAwesomeIcons.arrowRightFromBracket,
                          onTap: () {
                            homeController.logoutUser();
                          },
                          title: 'Log Out',
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Container(
                        width: Get.width,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.15),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30),
                            const Text(
                              'About',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Obx(() {
                              return userController.isLoading.value
                                  ? _buildShimmerLoading()
                                  : Text(
                                userController.userModel.value?.companyInfo?.description ??
                                    'Setup company info in settings',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w100, fontSize: 14),
                              );
                            }),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ),
              Positioned(
                top: 0,
                child: ProfileImageCard(
                  image: userController.userModel.value?.profilePicUrl ?? '',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        height: 40,
        width: Get.width - 40,
      ),
    );
  }
}

