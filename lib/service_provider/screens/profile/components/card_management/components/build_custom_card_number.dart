
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

import '../../../../../../client/controllers/user/user_controller.dart';

class CustomCardNumber extends StatelessWidget {
  const CustomCardNumber({
    super.key,
    required this.userController,
  });

  final UserController userController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Row(
              children: List.generate(4, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2),
                  child: Neumorphic(
                    style: const NeumorphicStyle(
                      shape: NeumorphicShape.convex,
                      depth: -10,
                      boxShape:
                      NeumorphicBoxShape.circle(),
                      color: Colors.black,
                    ),
                    child: const SizedBox(
                      height: 12,
                      width: 12,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(
              height: 10,
              width: 15,
            ),
            // spacing between groups
            Row(
              children: List.generate(4, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2),
                  child: Neumorphic(
                    style: const NeumorphicStyle(
                      shape: NeumorphicShape.convex,
                      depth: -10,
                      boxShape:
                      NeumorphicBoxShape.circle(),
                      color: Colors.black,
                    ),
                    child: const SizedBox(
                      height: 12,
                      width: 12,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
          width: 5,
        ),
        Row(
          children: [
            // spacing between groups
            Row(
              children: List.generate(4, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2),
                  child: Neumorphic(
                    style: const NeumorphicStyle(
                      shape: NeumorphicShape.convex,
                      depth: -10,
                      boxShape:
                      NeumorphicBoxShape.circle(),
                      color: Colors.black,
                    ),
                    child: const SizedBox(
                      height: 12,
                      width: 12,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(
              height: 10,
              width: 15,
            ),
            Text(
              userController
                  .userModel.value!.cardNumber!
                  .substring(userController.userModel
                  .value!.cardNumber!.length -
                  4),
              style: TextStyle(
                  fontSize: 26,
                  letterSpacing: 5,
                  color:
                  Colors.black.withOpacity(0.7)),
            ),
          ],
        )
      ],
    );
  }
}