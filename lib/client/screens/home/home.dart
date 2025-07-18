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
              Container(
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
                    return imagesContainer(
                      homeController.services[index].imageURL,
                      homeController.services[index].name,
                      index,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GestureDetector(
                  onTap: () {
                    if (isLoggedIn) {
                      Get.to(() => LeadFormScreen(), transition: Transition.cupertino);
                    } else {
                      CustomSnackbar.showSnackBar(
                        'You are almost there!',
                        'Please login to continue',
                        const Icon(Icons.error),
                        Theme.of(context).colorScheme.primary,
                        context,
                      );
                      Get.to(() => const StartPage(), transition: Transition.cupertino);
                    }
                  },
                  child: Container(
                    height: 80,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade300, Colors.blue.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade200,
                          offset: const Offset(0, 4),
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.add_circle, color: Colors.white, size: 30),
                        SizedBox(width: 15),
                        Text(
                          'Submit a Lead Request',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}

