import 'dart:ffi';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';
import 'package:shimmer/shimmer.dart';
import '../../controllers/user_chat/chats_controller.dart';
import '../../controllers/user_chat/typing_indicator.dart';
import '../../../shared/models/user/user_model.dart';
import '../../../shared/models/custom_offer_model.dart';
import '../../../shared/models/custom_order_model.dart';
import '../../../service_provider/widgets/custom_offer_form.dart';
import 'components/chat_app_bar.dart';
import '../../../services/custom_offer_payment_service.dart';
import '../../../services/notification_services.dart';
import 'package:uuid/uuid.dart';
import 'widgets/custom_offer_widget.dart';
import 'widgets/delivery_completion_widget.dart';

class ChatScreen extends StatelessWidget {
  final UserModel userModel;

  ChatScreen({super.key, required this.userModel});

  final ChatController chatController = Get.put(ChatController());
  final ScrollController _scrollController = ScrollController();
  final UserController userController = Get.find();

  @override
  Widget build(BuildContext context) {
    chatController.initializeChat(
        FirebaseAuth.instance.currentUser?.uid ?? '', userModel.uid);

    return WillPopScope(
      onWillPop: () async {
        chatController.fetchLastMessageData(chatController.users);
        chatController.stopTyping();
        return true;
      },
      child: Scaffold(
        appBar: ChatAppBar(
          userModel: userModel,
          chatController: chatController,
          isSelected: chatController.selectedMessageIds.isNotEmpty,
        ),
        body: Obx(() {
          if (!chatController.isInitialized.value) {
            return buildShimmerLoading(context);
          } else {
            return Column(
              children: [
                // Custom Offer StreamBuilder
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                    .collection('chat_room')
                    .doc(chatController.chatRoomId)
                    .collection('custom_offers')
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return SizedBox();
                    final offers = snapshot.data!.docs
                        .map((doc) => CustomOffer.fromMap(doc.data() as Map<String, dynamic>))
                        .toList();
                    return Column(
                      children: offers.map((offer) => CustomOfferWidget(
                        offer: offer,
                        isClient: userController.accountType == 'client',
                        chatRoomId: chatController.chatRoomId,
                      )).toList(),
                    );
                  },
                ),
                // Delivery Completion StreamBuilder
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                    .collection('chat_room')
                    .doc(chatController.chatRoomId)
                    .collection('delivery_completions')
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return SizedBox();
                    final deliveries = snapshot.data!.docs;
                    return Column(
                      children: deliveries.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return DeliveryCompletionWidget(
                          messageId: doc.id,
                          chatRoomId: chatController.chatRoomId,
                          isClient: userController.accountType == 'client',
                          providerId: data['providerId'] ?? '',
                          clientId: data['clientId'] ?? '',
                        );
                      }).toList(),
                    );
                  },
                ),
                Expanded(
                  child: buildMessageList(userModel.uid,
                      FirebaseAuth.instance.currentUser?.uid ?? "No user id"),
                ),
                Obx(() {
                  if (chatController.isOtherUserTyping.value) {
                    return const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                      child: TypingIndicator(),
                    );
                  } else {
                    return Container();
                  }
                }),
                // Show Send Custom Offer button for service providers
                if (userController.accountType == 'serviceProvider')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => CustomOfferForm(
                                  clientId: userModel.uid,
                                  chatId: chatController.chatRoomId,
                                ),
                              );
                            },
                            child: const Text('Send Custom Offer'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _sendDeliveryCompletedMessage(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Delivery Completed'),
                          ),
                        ),
                      ],
                    ),
                  ),
                buildMessageInput(context),
              ],
            );
          }
        }),
      ),
    );
  }

  Widget buildShimmerLoading(BuildContext context) {
    return ListView.builder(
      itemCount: 15,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.onSecondary.withOpacity(.15),
          highlightColor:
              Theme.of(context).colorScheme.onPrimary.withOpacity(.15),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16, top: 20),
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          color: Theme.of(context).colorScheme.onPrimary,
                          height: 20,
                          width: double.infinity,
                        ),
                        const SizedBox(height: 5),
                        Container(
                          color: Theme.of(context).colorScheme.onPrimary,
                          height: 15,
                          width: 100,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildMessageList(String receiver, String user) {
    return StreamBuilder<QuerySnapshot>(
      stream: chatController.getMessage(chatController.chatRoomId),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching messages'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return buildShimmerLoading(context);
        }
        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages'),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        });

        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs
              .map((document) => buildMessageItem(document, user, context))
              .toList(),
        );
      },
    );
  }

  Widget buildMessageItem(
    DocumentSnapshot document,
    String userId,
    BuildContext context,
  ) {
    final Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

    if (data == null) {
      return Container();
    }

    final String message = data['message'] ?? '';
    final String senderId = data['senderId'] ?? '';
    final String messageId = document.id;
    final Timestamp? timestamp = data['timeStamp'] as Timestamp?;
    final String? mediaUrl = data['mediaUrl'];
    final bool isDeliveryCompletion = data['isDeliveryCompletion'] ?? false;
    final String? deliveryCompletionId = data['deliveryCompletionId'];
    final DateTime time =
        timestamp != null ? timestamp.toDate() : DateTime.now();
    final String formattedTime = DateFormat('hh:mm a').format(time);
    final bool isCurrentUserSender = senderId == userId;

    if (message.isEmpty && (mediaUrl == null || mediaUrl.isEmpty) && !isDeliveryCompletion) {
      return Container();
    }

    // If this is a delivery completion message, show the widget
    if (isDeliveryCompletion && deliveryCompletionId != null) {
      return DeliveryCompletionWidget(
        messageId: deliveryCompletionId,
        chatRoomId: chatController.chatRoomId,
        isClient: userController.accountType == 'client',
        providerId: senderId,
        clientId: userId,
      );
    }

    return GestureDetector(
      onLongPress: () {
        chatController.toggleMessageSelection(messageId, isCurrentUserSender);
      },
      onTap: () {
        if (chatController.selectedMessageIds.isNotEmpty &&
            isCurrentUserSender) {
          chatController.toggleMessageSelection(messageId, isCurrentUserSender);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16, top: 15),
        child: Row(
          mainAxisAlignment: isCurrentUserSender
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Get.width * 0.6,
                ),
                child: Obx(() {
                  final bool isSelected =
                      chatController.selectedMessageIds.contains(messageId);

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withOpacity(.15),
                      ),
                      color: isSelected
                          ? Colors.red.withOpacity(0.4)
                          : isCurrentUserSender
                              ? Theme.of(context).colorScheme.onSecondary
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (mediaUrl != null && mediaUrl.isNotEmpty)
                          mediaUrl.contains('.png')
                              ? InkWell(
                                  child: Container(
                                    constraints: BoxConstraints(
                                        maxWidth: Get.width * 0.6),
                                    child: CachedNetworkImage(
                                      imageUrl: mediaUrl,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 200,
                                  constraints:
                                      BoxConstraints(maxWidth: Get.width * 0.6),
                                  child: const Center(
                                      child: Text('Video Preview')),
                                ),
                        if (message.isNotEmpty)
                          Container(
                            constraints:
                                BoxConstraints(maxWidth: Get.width * 0.6),
                            child: Text(
                              message,
                              style: TextStyle(
                                color: isCurrentUserSender
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Colors.black,
                              ),
                            ),
                          ),
                        const SizedBox(height: 5),
                        Text(
                          formattedTime,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMessageInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25, left: 10, right: 10, top: 15),
      child: Obx(() {
        return Column(
          children: [
            // If media is selected, display it (either image or video)
            if (chatController.media.value != null)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: chatController.isImage.value
                    ? Stack(
                  children: [
                    Image.file(
                      File(chatController.media.value!.path),
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                    Positioned(
                      right: 0,
                      top: 10,
                      child: InkWell(
                        onTap: () {
                          chatController.clearMedia(); // Clear the selected media
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            CupertinoIcons.xmark,
                            color: Colors.white70,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                    : SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.video_collection_rounded,
                        size: 50,
                        color: Colors.grey[700],
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: InkWell(
                          onTap: () {
                            chatController.clearMedia(); // Clear the selected media
                          },
                          child: const Icon(CupertinoIcons.xmark,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Message input field with send button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSecondary,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(.2),
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Message input field
                  Expanded(
                    child: TextField(
                      maxLines: null,
                      controller: chatController.messageController,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your message...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onChanged: (text) {
                        chatController.onMessageChanged(text);
                      },
                    ),
                  ),
                  // Media selection button
                  IconButton(
                    onPressed: () {
                      showMediaSelectionSheet(context);
                    },
                    icon: Icon(
                      Icons.image_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    onPressed: chatController.isMediaUploading.value
                        ? null
                        : () async {
                      if (chatController.media.value != null) {
                        chatController.isMediaUploading.value = true;
                        String? uploadedMediaUrl = await chatController.uploadMedia(
                          File(chatController.media.value!.path),
                          chatController.chatRoomId,
                          chatController.isImage.value,
                        );
                        chatController.isMediaUploading.value = false;
                        chatController.clearMedia();

                        // Send message with media
                        await chatController.sendMessage(
                          chatController.messageController.text,
                          userModel.uid,
                          context,
                          userController.userModel.value!.userName,
                          userModel.deviceToken as String,
                          uploadedMediaUrl,
                        );
                      } else {
                        await chatController.sendMessage(
                          chatController.messageController.text,
                          userModel.uid,
                          context,
                          userController.userModel.value!.userName,
                          userModel.deviceToken as String,
                          null,
                        );
                      }

                      chatController.messageController.clear();
                      chatController.stopTyping();
                      scrollToBottom();
                    },
                    icon: chatController.isMediaUploading.value
                        ? const SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Icon(
                      Icons.send,
                      color: chatController.canSend.value ||
                          chatController.media.value != null
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  void showMediaSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Theme.of(context).colorScheme.onSecondary,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.image,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                title: Text(
                  'Pick Image',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                onTap: () {
                  chatController.isImage.value = true;
                  Navigator.of(context).pop();
                  chatController.pickMedia(true);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.video_collection,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                title: Text(
                  'Pick Video',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                onTap: () {
                  chatController.isImage.value = false;
                  Navigator.of(context).pop();
                  chatController.pickMedia(false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendDeliveryCompletedMessage(BuildContext context) async {
    try {
      // Create delivery completion record
      final deliveryId = const Uuid().v4();
      await FirebaseFirestore.instance
          .collection('chat_room')
          .doc(chatController.chatRoomId)
          .collection('delivery_completions')
          .doc(deliveryId)
          .set({
        'id': deliveryId,
        'status': 'pending',
        'createdAt': Timestamp.now(),
        'providerId': FirebaseAuth.instance.currentUser!.uid,
        'clientId': userModel.uid,
      });

      // Send the delivery completed message
      final String message = 'Delivery completed. Please confirm.';
      await chatController.sendMessage(
        message,
        userModel.uid,
        context,
        userController.userModel.value!.userName,
        userModel.deviceToken ?? '',
        null,
      );

      // Add delivery completion widget to the message
      await FirebaseFirestore.instance
          .collection('chat_room')
          .doc(chatController.chatRoomId)
          .collection('message')
          .doc(chatController.lastMessageId)
          .update({
        'isDeliveryCompletion': true,
        'deliveryCompletionId': deliveryId,
      });

      chatController.messageController.clear();
      chatController.stopTyping();
      scrollToBottom();
    } catch (e) {
      print('Error sending delivery completed message: $e');
    }
  }
}
