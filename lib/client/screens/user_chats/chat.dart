import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../controllers/user_chat/chats_controller.dart';
import '../../models/message/last_message.dart';
import '../../../shared/models/user/user_model.dart';
import '../../widgets/custom_snackbar.dart';
import 'chat_screen.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  int totalChats = 0;

  Future<void> _onRefresh(ChatController chatController) async {
    await chatController.fetchAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Get.put(ChatController());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat',
          style: GoogleFonts.poppins(
            fontSize: Get.width * 0.06,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            Obx(() {
              final sortedUsers = chatController.sortedUsers;
              return _buildTopBar(sortedUsers.length, context, chatController);
            }),
            const SizedBox(height: 20),
            Expanded(
              child: _buildChatListView(context, chatController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatListView(BuildContext context, ChatController chatController) {
    return Obx(() {
      if (chatController.isInitialized.value) {
        final sortedUsers = chatController.sortedUsers;

        if (sortedUsers.isEmpty) {
          return Center(child: Lottie.asset('assets/lottie/empty.json'));
        }

        return RefreshIndicator(
          onRefresh: () => _onRefresh(chatController),
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: sortedUsers.length,
            itemBuilder: (context, index) {
              final user = sortedUsers[index].key;
              final lastMessageData = sortedUsers[index].value;

              return Dismissible(
                key: Key(user.uid),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await _confirmDeleteChat(context, user.userName);
                },
                onDismissed: (direction) {
                  chatController.deleteChat(user.uid);
                  CustomSnackbar.showSnackBar(
                      'Chat deleted',
                      '${user.userName} chat has been deleted.',
                      const Icon(Icons.check),
                      Theme.of(context).colorScheme.onPrimary,
                      context);
                },
                child: InkWell(
                  onTap: () {
                    chatController.markMessagesAsRead(
                      FirebaseAuth.instance.currentUser!.uid,
                      user.uid,
                    );
                    Get.to(() => ChatScreen(userModel: user),
                        transition: Transition.cupertino);
                  },
                  child: _buildUserListItem(user, lastMessageData!, context),
                ),
              );
            },
          ),
        );
      } else {
        return buildShimmerLoading();
      }
    });
  }

  Widget _buildTopBar(int totalChats, BuildContext context, ChatController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTopBarItem(Icons.people_alt_outlined, 'All', totalChats, context, controller),
          Obx(
                () => _buildTopBarItem(Icons.filter_list, controller.sortOrder.value, 2, context, controller),
          )
        ],
      ),
    );
  }

  Widget _buildTopBarItem(IconData icon, String label, int value, BuildContext context, ChatController controller) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary.withOpacity(.8),
          size: 22,
        ),
        const SizedBox(width: 7),
        GestureDetector(
          onTap: () {
            if (label != 'All') {
              controller.changeSortOrder();
            }
          },
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary.withOpacity(.9),
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(width: 7),
        if (value.isGreaterThan(0) && !(label == 'Oldest') && !(label == 'Newest'))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                value.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          )
        else
          const SizedBox(),
      ],
    );
  }

  Widget _buildUserListItem(UserModel user, LastMessageData lastMessageData, BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;

    if (auth.currentUser?.email == user.email) {
      return const SizedBox();
    }

    final profilePicUrl = user.profilePicUrl;
    final lastMessage = lastMessageData.message;
    final senderId = lastMessageData.senderId;
    final isCurrentUser = senderId == auth.currentUser!.uid;
    final lastMessagePrefix = isCurrentUser ? 'You: ' : '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSecondary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: Hero(
          tag: user.userName + user.uid,
          child: CircleAvatar(
            backgroundImage: profilePicUrl != null
                ? NetworkImage(profilePicUrl)
                : null,
            radius: 24,
            child: profilePicUrl == null
                ? const Icon(Icons.person, size: 24)
                : null,
          ),
        ),
        title: Text(
          user.userName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        subtitle: Text(
          '$lastMessagePrefix$lastMessage',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        trailing: _buildTrailing(lastMessageData, context),
      ),
    );
  }

  Widget _buildTrailing(LastMessageData lastMessageData, BuildContext context) {
    final unreadCount = lastMessageData.count;

    return unreadCount > 0
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: Text(
            unreadCount.toString(),
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _formatTime(lastMessageData.timestamp),
          style: TextStyle(color: Colors.blueGrey.shade300),
        ),
      ],
    )
        : Text(
      _formatTime(lastMessageData.timestamp),
      style: TextStyle(color: Colors.blueGrey.shade300),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final time = TimeOfDay.fromDateTime(dateTime);
    return '${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  Widget buildShimmerLoading() {
    return ListView.builder(
      itemCount: 15,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            radius: 24,
          ),
          title: Container(
            width: 100,
            height: 10,
            color: Colors.grey.shade300,
          ),
          subtitle: Container(
            width: 200,
            height: 10,
            color: Colors.grey.shade300,
          ),
        );
      },
    );
  }

  Future<bool?> _confirmDeleteChat(BuildContext context, String userName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete chat with $userName?'),
        content: const Text('Are you sure you want to delete this chat?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
