import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pests247/client/screens/on_board/start.dart';
import 'package:pests247/client/widgets/custom_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientDeleteAccountController extends GetxController {
  var isLoading = false.obs;
  late String userName;
  late String accountCreationDate;

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    final user = auth.currentUser;
    if (user != null) {
      userName = user.displayName ?? 'No Name';
      accountCreationDate = user.metadata.creationTime?.toString() ?? 'Unknown';
    }
  }

  Future<void> confirmDeleteAccount() async {
    bool? isConfirmed = await _showConfirmationDialog();
    if (isConfirmed != null && isConfirmed) {
      await deleteAccount();
    }
  }


  Future<void> deleteAccount() async {
    final user = auth.currentUser;
    if (user != null) {
      isLoading.value = true;

      try {
        await _deleteChatRooms(user.uid);
        await _deleteUserFromLeads(user.uid);
        await user.delete();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', false);

        CustomSnackbar.showSnackBar(
          'Success',
          'Your account has been deleted successfully.',
          const Icon(Icons.check, color: Colors.green),
          Colors.green,
          Get.context!,
        );
        await auth.signOut();
        Get.offAll(() => const StartPage());
      } catch (e) {
        isLoading.value = false;

        print("Error during account deletion: $e");

        String errorMessage = 'Failed to delete account. Please try again.';
        if (e is FirebaseAuthException) {
          if (e.code == 'requires-recent-login') {
            errorMessage = 'Please log in again to delete your account.';
          }
        }

        CustomSnackbar.showSnackBar(
          'Error',
          errorMessage,
          const Icon(Icons.error, color: Colors.red),
          Colors.red,
          Get.context!,
        );
      }
    }
  }


  Future<void> _deleteChatRooms(String userId) async {
    final chatRoomsSnapshot = await firestore.collection('chat_room').get();

    if (chatRoomsSnapshot.docs.isNotEmpty) {
      for (var doc in chatRoomsSnapshot.docs) {
        if (doc.id.contains(userId)) {
          try {
            await firestore.collection('chat_room').doc(doc.id).delete();
            print('Deleted chat room: ${doc.id}');
          } catch (e) {
            print('Error deleting chat room: $e');
          }
        }
      }
    } else {
      print('No chat rooms found for user: $userId');
    }
  }

  Future<void> _deleteUserFromLeads(String userId) async {
    try {
      final leadsSnapshot = await firestore.collection('leads').get();

      if (leadsSnapshot.docs.isNotEmpty) {
        for (var leadDoc in leadsSnapshot.docs) {
          final leadData = leadDoc.data();
          final leadUserId = leadData['userId'];

          if (leadUserId == userId) {
            await firestore.collection('leads').doc(leadDoc.id).delete();
            print('Successfully deleted lead: ${leadDoc.id}');
          }
        }
      } else {
        print('No leads found for the user: $userId');
      }
    } catch (e) {
      print('Error while deleting user from leads: $e');
    }
  }




  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: Get.context!,
      builder: (BuildContext context) {
        return Platform.isAndroid
            ? AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
              'Are you sure you want to delete your account? This action is irreversible.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Get.back(result: false);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Get.back(result: true);
              },
            ),
          ],
        )
            : CupertinoAlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
              'Are you sure you want to delete your account? This action is irreversible.'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Get.back(result: false);
              },
            ),
            CupertinoDialogAction(
              child: const Text('Delete'),
              onPressed: () {
                Get.back(result: true);
              },
            ),
          ],
        );
      },
    );
  }
}
