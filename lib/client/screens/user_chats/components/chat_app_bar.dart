import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../shared/models/user/user_model.dart';
import '../../../controllers/user_chat/chats_controller.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModel userModel;
  final ChatController chatController;
  final bool isSelected;

  const ChatAppBar({
    super.key,
    required this.userModel,
    required this.chatController,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Hero(
            tag: userModel.userName + userModel.uid,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: userModel.profilePicUrl != null &&
                  userModel.profilePicUrl!.isNotEmpty
                  ? NetworkImage(userModel.profilePicUrl as String)
                  : null,
              child: userModel.profilePicUrl == null
                  ? const Icon(Icons.person, size: 18, color: Colors.black)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              userModel.userName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ),
        ],
      ),
      actions: [
        Obx(() {
          return chatController.selectedMessageIds.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    print(chatController.selectedMessageIds);
                    showDeleteConfirmation(context, () {
                      chatController.deleteSelectedMessages(
                        FirebaseAuth.instance.currentUser!.uid,
                        userModel.uid,
                      );
                    });
                  },
                  icon: const Icon(Icons.delete),
                )
              : const SizedBox.shrink(); // Empty widget when no messages selected
        }),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

Future<void> showDeleteConfirmation(
    BuildContext context, Function onConfirm) async {
  if (Platform.isIOS) {
    await showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete the selected messages?"),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  } else {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete the selected messages?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}