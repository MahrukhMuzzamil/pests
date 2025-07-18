import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';
import 'package:pests247/client/widgets/custom_snackbar.dart';
import 'package:pests247/service_provider/screens/credits/credits_screen.dart';

Row HomeAppBar() {
  final UserController userController = Get.find();
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const Icon(
        Ionicons.person_circle_outline,
        size: 45,
      ),
      const SizedBox(width: 10),
      Text(
        userController.userModel.value!.userName,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const Spacer(),
      GestureDetector(
        onTap: () {
          Get.to(() => const CreditsScreen(),transition: Transition.cupertino);
        },
        child: Container(
          width: 100,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.blue,
          ),
          alignment: Alignment.center,
          child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 4,),
                Text(
                  "Top up",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ]),
        ),
      )
    ],
  );
}
