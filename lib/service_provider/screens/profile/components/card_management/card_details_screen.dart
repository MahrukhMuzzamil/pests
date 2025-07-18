import 'dart:ui';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';
import 'package:pests247/client/widgets/custom_button.dart';
import 'package:pests247/service_provider/screens/profile/components/card_management/change_card_screen.dart';

import 'components/build_card.dart';

class CardDetailsScreen extends StatelessWidget {
  const CardDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find();
    bool isCardEmpty = userController.userModel.value!.cardNumber!.isEmpty ||
        userController.userModel.value!.cardExpiry!.isEmpty;

    return NeumorphicBackground(
      child: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              buildCard(context),
              Padding(
                padding: const EdgeInsets.only(
                    left: 35, right: 35, top: 60, bottom: 30),
                child: CustomButton(
                  height: 45,
                  text: isCardEmpty ? "Add card" : "Change card",
                  textStyle: const TextStyle(fontSize: 15, color: Colors.white),
                  onPressed: () => {
                    Get.to(() => ChangeCardScreen(),
                        transition: Transition.cupertino)
                  },
                  isLoading: false,
                  backgroundColor: Colors.blue,
                  tag: '',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
