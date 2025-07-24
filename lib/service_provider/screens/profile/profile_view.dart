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
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' as material;
import 'package:pests247/services/stripe_service.dart';

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
                    // Packages Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Available Packages',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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
                              return Column(
                                children: packages.map((pkg) => material.Card(
                                  // Use material.Card to avoid conflict with Stripe's Card
                                  child: ListTile(
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
                                          const SnackBar(content: Text('Please log in to purchase a package.')),
                                        );
                                        return;
                                      }
                                      try {
                                        // Use the existing StripeService for payment
                                        final paymentSuccess = await StripeService.instance.makePayment(context, pkg.credits, pkg.price);
                                        if (paymentSuccess) {
                                          // After successful payment, update the user's visibility package info
                                          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                                            'visibilityPackage': pkg.id,
                                            'visibilityPackageName': '${pkg.credits} Credits',
                                            'visibilityPackagePrice': pkg.price,
                                            'visibilityPackagePurchasedAt': FieldValue.serverTimestamp(),
                                            'visibilityPackageExpiry': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Visibility package purchased successfully!')),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Payment failed or cancelled: $e')),
                                        );
                                      }
                                    },
                                  ),
                                )).toList(),
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
                            const SizedBox(height: 40),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: Get.height * .35,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ProfileImageCard(
                image: userController.userModel.value?.profilePicUrl ?? '',
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

