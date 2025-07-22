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
import 'package:pests247/service_provider/models/company_info/company_info_model.dart';
import 'package:pests247/shared/utils/distance_utils.dart'; // import your utility
import 'package:geolocator/geolocator.dart';

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

  Future<List<CompanyInfo>> getRankedBusinesses(List<CompanyInfo> businesses, double userLat, double userLng) async 
  {

    List<CompanyInfo> scoredCompanies = [];

    for (var company in businesses) {
      // Handle null values
      double rating = company.averageRating ?? 0.0;
      int package = company.premiumPackage;
      double? distance;

      if (company.latitude != null && company.longitude != null) {
        distance = haversine(userLat, userLng, company.latitude!, company.longitude!);
      }

      // Calculate rankScore
      double rankScore = 0.0;

      // Base score from rating and package (always available)
      rankScore += rating * 2;          // weight for rating
      rankScore += package * 5;         // weight for package

      // If location is available, factor proximity in score
      if (distance != null) {
        rankScore += (10 - (distance / 5)).clamp(0, 10); // Higher proximity = higher score
      }

      // Add distance info for UI
      company = company.copyWith(
        distanceFromUser: distance,
        rankScore: rankScore,
      );

      scoredCompanies.add(company);
    }

    // Group by package
    List<CompanyInfo> package1 = scoredCompanies.where((c) => c.premiumPackage == 1).toList();
    List<CompanyInfo> package2 = scoredCompanies.where((c) => c.premiumPackage == 2).toList();
    List<CompanyInfo> package3 = scoredCompanies.where((c) => c.premiumPackage == 3).toList();
    List<CompanyInfo> package0 = scoredCompanies.where((c) => c.premiumPackage == 0).toList();

    // Sort each group by rankScore descending
    package1.sort((a, b) => (b.rankScore ?? 0).compareTo(a.rankScore ?? 0));
    package2.sort((a, b) => (b.rankScore ?? 0).compareTo(a.rankScore ?? 0));
    package3.sort((a, b) => (b.rankScore ?? 0).compareTo(a.rankScore ?? 0));
    package0.sort((a, b) => (b.rankScore ?? 0).compareTo(a.rankScore ?? 0));

    // Respect priority
    List<CompanyInfo> finalRanked = [];
    finalRanked.addAll(package1.take(5));       // Top 5 from package 1
    finalRanked.addAll(package2.take(10));      // Top 10 from package 2
    finalRanked.addAll(package3.take(20));      // Top 20 from package 3
    finalRanked.addAll(package0);               // Add rest (no premium)

    return finalRanked;
}


    Future<Position?> getCurrentLocation() async 
    {
      print('[HomeController] getCurrentLocation called');
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          print('[HomeController] Location services are disabled.');
          return null;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          print('[HomeController] Location permission denied, requesting...');
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            print('[HomeController] Location permission denied after request.');
            return null;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          print('[HomeController] Location permission denied forever.');
          return null;
        }

        Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        print('[HomeController] Got position: ${pos.latitude}, ${pos.longitude}');
        return pos;
      } catch (e) {
        print('[HomeController] Error getting location: $e');
        return null;
      }
    }

    Future<bool> requestLocationPermission() async 
    {
      print('[HomeController] Requesting location permission...');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('[HomeController] Location services are disabled.');
        // Optionally prompt user to enable location services.
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print('[HomeController] Location permission denied, requesting...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('[HomeController] Location permission denied after request.');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('[HomeController] Location permission denied forever.');
        // Permissions are permanently denied
        return false;
      }

      print('[HomeController] Location permission granted.');
      return true;
    }



}
