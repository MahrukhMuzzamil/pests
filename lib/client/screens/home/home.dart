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

    // Initialize controllers once
    homeController = Get.put(HomeController(), permanent: true);
    userController = Get.put(UserController(), permanent: true);

    // Fetch user data once
    userController.fetchUser();
  }

  void _checkLoginStatus() async {
    bool status = await AppController.checkLoginStatus();
    setState(() {
      isLoggedIn = status;
    });
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
                padding: const EdgeInsets.only(left: 20.0, right: 10.0, bottom: 20),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    height: MediaQuery.of(context).size.height * .17,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: homeController.services.length,
                      itemBuilder: (context, index) {
                        if (index >= homeController.services.length) return const SizedBox();
                        return imagesContainer(
                          homeController.services[index].imageURL,
                          homeController.services[index].name,
                          index,
                        );
                      },
                    ),
                  ),
            ],
          ),
        );
      }),
    );
  }
}

