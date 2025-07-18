import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

Widget buildSuccessScreen() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset('assets/lottie/success_animation.json', height: Get.width),
        const SizedBox(height: 20),
        const Text('Success! Your request has been submitted.',style: TextStyle(fontSize: 16),textAlign: TextAlign.center,),
      ],
    ),
  );
}
