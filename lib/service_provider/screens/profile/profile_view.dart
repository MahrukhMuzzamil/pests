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

