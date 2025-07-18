import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/others/pest_model.dart';
import '../../../shared/models/user/user_model.dart';
import '../../screens/on_board/start.dart';

class HomeController extends GetxController {
  UserModel? highestRatedUser;
  RxList<Map<String, dynamic>> newUpdates = <Map<String, dynamic>>[].obs;
  List<ServiceCategory> services = allCategories.where((c) => c.isActive).toList();

  @override
  void onInit() {
    super.onInit();
    fetchHighestRatedUser();
    fetchNewUpdates();
  }

  Future<void> fetchNewUpdates() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('newUpdates')
          .orderBy('updateTime', descending: true)
          .get();

      newUpdates.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'updateNumber': data['updateNumber'] ?? '',
          'updateTitle': data['updateTitle'] ?? '',
          'updateDescription': data['updateDescription'] ?? '',
          'updatedTimeStamp': data['updatedTimeStamp'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error fetching updates: $e');
    }
  }


  Future<void> fetchHighestRatedUser() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('accountType', isEqualTo: 'serviceProvider')
        .get();

    double highestAvgRating = 0.0;
    UserModel? highestRatedUser;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final reviews = data['reviews'] as List<dynamic>?;

      if (reviews != null && reviews.isNotEmpty) {
        double totalRating = 0;
        int reviewCount = 0;

        for (var review in reviews) {
          final rating = review['reviewUserRating'] as num?;
          if (rating != null) {
            totalRating += rating.toDouble();
            reviewCount++;
          }
        }

        if (reviewCount > 0) {
          double avgRating = totalRating / reviewCount;

          if (avgRating > highestAvgRating) {
            highestAvgRating = avgRating;
            highestRatedUser = UserModel.fromFirestore(doc);
          }
        }
      }
    }

    if (highestRatedUser != null) {
      this.highestRatedUser = highestRatedUser;
      update();
    }
  }



  Future<void> logoutUser() async {
    bool? confirmLogout = await Get.dialog<bool>(
      Platform.isIOS ? CupertinoAlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ):AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmLogout == true) {
      try {
        await FirebaseAuth.instance.signOut();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("isLoggedIn", false);
        prefs.setString("accountType", '');
        prefs.setString("userId", '');
        UserController userController = Get.find();
        userController.userModel.value = null;
        if (Get.isRegistered<UserController>()) {
          Get.delete<UserController>();
        }
        // Navigate to the start page
        Get.offAll(const StartPage(), transition: Transition.cupertino);
      } catch (e) {
        print('Error during logout: $e');
      }
    }
  }
}
