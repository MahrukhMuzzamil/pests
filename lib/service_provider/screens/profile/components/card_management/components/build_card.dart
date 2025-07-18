import 'dart:ui';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';

import 'build_custom_card_number.dart';

Widget buildCard(BuildContext context) {
  final UserController userController = Get.find();

  return Neumorphic(
    style: NeumorphicStyle(
      depth: 10,
      boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
      shape: NeumorphicShape.flat,
    ),
    child: Neumorphic(
      margin: const EdgeInsets.all(8),
      style: NeumorphicStyle(
        depth: 10,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        shape: NeumorphicShape.flat,
      ),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(minHeight: 500, maxHeight: Get.height * .65),
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.blue.withOpacity(1),
                        Colors.blueGrey.withOpacity(1),
                      ],
                    ),
                  ),
                ),
              ),
              Stack(
                children: <Widget>[
                  Positioned(
                    top: 12,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          "VISA",
                          style: TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Obx(() => (userController
                                    .userModel.value!.cardExpiry!.isEmpty ||
                                userController
                                    .userModel.value!.cardNumber!.isEmpty)
                            ? Text(
                                "Please set up \nyour card details",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white.withOpacity(0.7)),
                              )
                            : CustomCardNumber(userController: userController))
                      ],
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 16,
                    child: SizedBox(
                      height: 50,
                      child: Neumorphic(
                        style: NeumorphicStyle(
                          depth: 5,
                          intensity: 0.8,
                          lightSource: LightSource.topLeft,
                          boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(12),
                          ),
                        ),
                        child: RotatedBox(
                          quarterTurns: 2,
                          child: Image.asset("assets/images/chip.png"),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 16,
                    child: Column(
                      children: <Widget>[
                        userController.userModel.value!.cardExpiry!.isEmpty ||
                                userController
                                    .userModel.value!.cardNumber!.isEmpty
                            ? Text(
                                "--/--",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white.withOpacity(0.7)),
                              )
                            : Text(
                                userController.userModel.value!.cardExpiry!,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white.withOpacity(0.7)),
                              ),
                        const SizedBox(
                          height: 8,
                        ),
                        Stack(
                          children: <Widget>[
                            Neumorphic(
                              style: const NeumorphicStyle(
                                shape: NeumorphicShape.convex,
                                depth: -10,
                                boxShape: NeumorphicBoxShape.circle(),
                                color: Colors.red,
                              ),
                              child: const SizedBox(
                                height: 30,
                                width: 30,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 18),
                              child: Neumorphic(
                                style: const NeumorphicStyle(
                                  color: Colors.orange,
                                  shape: NeumorphicShape.convex,
                                  boxShape: NeumorphicBoxShape.circle(),
                                  depth: 10,
                                ),
                                child: const SizedBox(
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

