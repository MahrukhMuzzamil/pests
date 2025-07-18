import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../client/controllers/user/user_controller.dart';
import '../../../../client/screens/client_bottom_nav_bar.dart';
import '../../../../client/widgets/custom_snackbar.dart';
import '../../../../service_provider/screens/service_provider_bottom_nav_bar.dart';



class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final UserController userController = Get.put(UserController());

  var obscureText = true.obs;
  final formKey = GlobalKey<FormState>();
  var isLoading = false.obs;

  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }

  void loginUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      isLoading.value = true;
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      User? userData = userCredential.user;

      if (!context.mounted) return;

      if (userData != null) {
        if (userData.emailVerified) {
          String userUid = userData.uid;
          String userRole = await fetchUserRoleFromBackend(userUid);
          String? deviceToken = await FirebaseMessaging.instance.getToken();
          print(deviceToken);

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userData.uid)
              .update({
            'deviceToken': deviceToken,
          });

          if (userRole == "client") {
            await prefs.setBool("isLoggedIn", true);
            await prefs.setString("accountType", 'client');
            await prefs.setString("userId", userUid);
            await userController.fetchUser();
            emailController.clear();
            passwordController.clear();
            Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(builder: (context) => const ClientBottomNavBar()),
                  (route) => false,
            );
          } else {
            await prefs.setBool("isLoggedIn", true);
            await prefs.setString("accountType", 'serviceProvider');
            await prefs.setString("userId", userUid);
            await userController.fetchUser();
            emailController.clear();
            passwordController.clear();
            Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(builder: (context) => const ServiceProviderBottomNavBar()),
                  (route) => false,
            );
          }
        } else {
          await userData.sendEmailVerification();
          CustomSnackbar.showSnackBar(
            'Verification Email Sent',
            'A verification email has been sent to your account',
            const Icon(Icons.email),
            Colors.blue,
            context,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      String errorMessage = "An undefined error occurred";
      print(e);

      if (e.code == 'user-disabled') {
        errorMessage = 'User has been disabled';
      } else if (e.code == 'too-many-requests') {
        errorMessage =
        'Too many unsuccessful login attempts. Please try again later.';
      } else {
        errorMessage = 'Invalid email or password';
      }

      CustomSnackbar.showSnackBar(
        'Login Error',
        errorMessage,
        const Icon(Icons.error),
        Colors.red,
        context,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> fetchUserRoleFromBackend(String uid) async {
    DocumentSnapshot userDoc =
    await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc.get('accountType') as String;
  }
}
