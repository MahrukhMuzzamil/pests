import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';
import 'components/credit_history_card.dart';
import 'components/home_appbar.dart';
import 'components/info_card.dart';

class CreditsHistoryScreen extends StatelessWidget {
  const CreditsHistoryScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find();

    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeAppBar(),
            const SizedBox(height: 20),
            const InfoCard(),
            const SizedBox(height: 20),
            const Text(
              "History",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 20),
            Obx(
                  () => Expanded(
                child: userController.userModel.value?.creditHistoryList == null ||
                    userController.userModel.value!.creditHistoryList!.isEmpty
                    ? const Center(
                  child: Text(
                    "No credit history available.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                )
                    : ListView.separated(
                  itemBuilder: (context, index) {
                    // Sort the list by date in descending order
                    final sortedList = userController
                        .userModel.value!.creditHistoryList!
                        .toList()
                      ..sort((a, b) => b.date!.compareTo(a.date!));

                    return CreditHistoryCard(
                      creditHistoryModel: sortedList[index],
                    );
                  },
                  separatorBuilder: (context, index) =>
                  const SizedBox(height: 10),
                  itemCount: userController
                      .userModel.value!.creditHistoryList!.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
