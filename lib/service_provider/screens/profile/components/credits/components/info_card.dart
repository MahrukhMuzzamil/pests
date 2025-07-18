import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:line_icons/line_icons.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find();
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(.4),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 25,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total credits",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          Obx( () =>
            Row(
              children: [
                Text(
                  userController.userModel.value!.credits.toString(),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.credit_score),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    final credits = userController.userModel.value?.credits ?? 0;
                    final responseCount = (credits / 5).ceil();

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        if (Platform.isAndroid) {
                          return AlertDialog(
                            title: const Text("Credit Information",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                            content: Text("About $responseCount responses. You can respond to given number of clients requests"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          );
                        } else if (Platform.isIOS) {
                          return CupertinoAlertDialog(
                            title: const Text("Credit Information"),
                            content: Text("About $responseCount responses. You can respond to given number of clients requests"),
                            actions: [
                              CupertinoDialogAction(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          );
                        }
                        return const SizedBox
                            .shrink();
                      },
                    );
                  },
                  child: const Icon(
                    IconlyBold.info_circle,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
