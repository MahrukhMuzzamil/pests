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
import 'package:geocoding/geocoding.dart';  // For Location and locationFromAddress


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

  Future<void> fetchAndStoreClientLocation(BuildContext context) async 
  {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Show a prompt to enable location services
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // fallback to manual entry
        await manualLocationFallback(context);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // fallback to manual entry
      await manualLocationFallback(context);
      return;
    }

    // Fetch current position
    Position position = await Geolocator.getCurrentPosition();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'latitude': position.latitude,
      'longitude': position.longitude,
    });
  }

  Future<void> manualLocationFallback(BuildContext context) async 
  {
    String? address = await showDialog<String>(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: Text("Enter Your Location"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "e.g. 123 Street, City"),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context, controller.text);
                },
                child: Text("Submit")),
          ],
        );
      },
    );

    if (address != null && address.isNotEmpty) {
      try {
        List<Location> locations = await locationFromAddress(address);
        if (locations.isNotEmpty) {
          Location location = locations.first;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({
            'latitude': location.latitude,
            'longitude': location.longitude,
          });
        }
      } catch (e) {
        print("Error geocoding address: $e");
      }
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

  Future<List<CompanyInfo>> getRankedBusinesses(
      List<CompanyInfo> businesses, double? userLat, double? userLng) async {
    
    List<CompanyInfo> scoredCompanies = [];

    for (var company in businesses) {
      double rating = company.averageRating ?? 0.0;
      int package = company.premiumPackage;
      double? distance;

      if (userLat != null && userLng != null && 
          company.latitude != null && company.longitude != null) {
        distance = haversine(userLat, userLng, company.latitude!, company.longitude!);
      }

      // RankScore calculation
      double rankScore = 0.0;
      rankScore += rating * 2;       // weight for rating
      rankScore += package * 5;      // weight for package

      // Apply proximity boost only if distance is known
      if (distance != null) {
        double proximityScore = (10 - (distance / 5)).clamp(0, 10);
        rankScore += proximityScore;
      }

      // Attach runtime values to company object
      company = company.copyWith(
        distanceFromUser: distance,
        rankScore: rankScore,
      );

      scoredCompanies.add(company);
    }

    // Group by package (3=Gold highest, then 2=Silver, 1=Platinum, 0=None)
    List<CompanyInfo> package3 = scoredCompanies.where((c) => c.premiumPackage == 3).toList();
    List<CompanyInfo> package2 = scoredCompanies.where((c) => c.premiumPackage == 2).toList();
    List<CompanyInfo> package1 = scoredCompanies.where((c) => c.premiumPackage == 1).toList();
    List<CompanyInfo> package0 = scoredCompanies.where((c) => c.premiumPackage == 0).toList();

    // Sort each by descending rankScore
    package3.sort((a, b) => (b.rankScore ?? 0).compareTo(a.rankScore ?? 0));
    package2.sort((a, b) => (b.rankScore ?? 0).compareTo(a.rankScore ?? 0));
    package1.sort((a, b) => (b.rankScore ?? 0).compareTo(a.rankScore ?? 0));
    package0.sort((a, b) => (b.rankScore ?? 0).compareTo(a.rankScore ?? 0));

    // Respect max slot per package tier
    List<CompanyInfo> finalRanked = [];
    finalRanked.addAll(package1.take(5));
    finalRanked.addAll(package2.take(10));
    finalRanked.addAll(package3.take(20));
    finalRanked.addAll(package0);

    return finalRanked;
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
