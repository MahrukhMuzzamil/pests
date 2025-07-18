import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/screens/client_bottom_nav_bar.dart';
import '../../controllers/lead_question_form/lead_question_form_controller.dart';
import '../../controllers/user/user_controller.dart';
import 'components/screens/build_confirmation_screen.dart';
import 'components/screens/build_email_screen.dart';
import 'components/screens/build_hiring_decision_screen.dart';
import 'components/screens/build_location_screen.dart';
import 'components/screens/build_pests_screen.dart';
import 'components/screens/build_property_type_screen.dart';
import 'components/screens/build_services_screen.dart';
import 'components/screens/build_sightings_screen.dart';
import 'components/screens/build_success_screen.dart';
import 'components/screens/build_additional_details_screen.dart';

class LeadFormScreen extends StatelessWidget {
  final LeadsFormController controller = Get.put(LeadsFormController());
  final UserController userController = Get.put(UserController());

  LeadFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Obx(() => controller.currentPage.value > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            controller.previousPage();
          },
        )
            : Container()),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearAll();
              Get.offAll(const ClientBottomNavBar(),transition: Transition.cupertino);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: Obx(() {
        return IndexedStack(
          index: controller.currentPage.value,
          children: [
            buildPropertyTypeScreen(controller),
            buildPestsScreen(controller),
            buildSightingsScreen(controller),
            buildServicesScreen(controller),
            buildHiringDecisionScreen(controller),
            buildLocationScreen(controller),
            buildEmailScreen(controller),
            buildAdditionalDetailsScreen(controller), // Add the new screen here
            buildConfirmationScreen(context, controller, userController),
            buildSuccessScreen(),
          ],
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          bool isNextEnabled = false;

          switch (controller.currentPage.value) {
            case 0:
              isNextEnabled = controller.isPropertyTypeSelected;
              break;
            case 1:
              isNextEnabled = controller.arePestsSelected;
              break;
            case 2:
              isNextEnabled = controller.isFrequencySelected;
              break;
            case 3:
              isNextEnabled = controller.areServicesSelected;
              break;
            case 4:
              isNextEnabled = controller.isHiringDecisionSelected;
              break;
            case 5:
              isNextEnabled = controller.location.isNotEmpty;
              break;
            case 6:
              isNextEnabled = controller.isEmailValid;
              break;
            case 7:
              isNextEnabled = controller.additionalDetails.value.isNotEmpty;
              break;
            case 8:
              isNextEnabled = true;
              break;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
            child: ElevatedButton(
              onPressed: (controller.currentPage.value == 9) || isNextEnabled
                  ? () {
                if (controller.currentPage.value == 8) {
                  controller.verifyAndSubmit(context, userController);
                } else if (controller.currentPage.value == 9) {
                  controller.clearAll();
                  Get.offAll(const ClientBottomNavBar(),transition: Transition.cupertino);
                } else {
                  controller.nextPage();
                }
              }
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: (controller.currentPage.value == 9)
                    ? Theme.of(context).colorScheme.primary
                    : (isNextEnabled
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ))
                  : Text(
                controller.currentPage.value == 9
                    ? 'Done'
                    : (controller.currentPage.value == 8
                    ? 'Submit'
                    : 'Next'),
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          );
        }),
      ),
    );
  }
}
