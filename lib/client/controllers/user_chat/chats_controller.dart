import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../services/notification_services.dart';
import '../../models/message/last_message.dart';
import '../../models/message/message.dart';
import '../../../shared/models/user/user_model.dart';

class ChatController extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final TextEditingController messageController = TextEditingController();
  var isMessageEmpty = true.obs;
  var isOtherUserTyping = false.obs;
  late String chatRoomId;
  var unreadMessageCountPerUser = 0.obs;
  var canSend = true.obs;
  var isInitialized = false.obs;
  var isFriendStatus = 'accepted'.obs;
  var users = <UserModel>[].obs;
  var lastMessageData = <UserModel, LastMessageData>{}.obs;
  var sortOrder = 'Newest'.obs;
  var backgroundColor = Colors.grey.obs;
  var primaryColor = Colors.black.obs;
  var currentPage = 0.obs;
  var selectedMessageIds = <String>[].obs;
  RxBool isImage = false.obs;
  Rx<XFile?> media = Rx<XFile?>(null);
  RxBool isMediaUploading = false.obs;
  String? lastMessageId; // Track the last sent message ID

  void onMessageChanged(String message) {
    canSend.value = message.trim().isNotEmpty || media.value != null;
  }

  void clearMedia() {
    media.value = null;
    onMessageChanged(messageController.text);
  }

  Future<void> pickMedia(bool isImage) async {
    XFile? selectedMedia;
    if (isImage) {
      selectedMedia =
          await ImagePicker().pickImage(source: ImageSource.gallery);
    } else {
      selectedMedia =
          await ImagePicker().pickVideo(source: ImageSource.gallery);
    }

    if (selectedMedia != null) {
      media.value = selectedMedia;
    }
  }

  void toggleMessageSelection(String messageId, bool isCurrentUserSender) {
    if (!isCurrentUserSender) return;

    if (selectedMessageIds.contains(messageId)) {
      selectedMessageIds.remove(messageId);
    } else {
      selectedMessageIds.add(messageId);
    }
  }

  void clearSelection() {
    selectedMessageIds.clear();
  }

  void deleteSelectedMessages(String senderId, String receiverId) async {
    final chatId = getChatRoomId(senderId, receiverId);
    final messageCollection = FirebaseFirestore.instance
        .collection('chat_room')
        .doc(chatId)
        .collection('message');

    for (String messageId in selectedMessageIds) {
      try {
        DocumentSnapshot messageSnapshot =
            await messageCollection.doc(messageId).get();

        if (messageSnapshot.exists) {
          var messageData = messageSnapshot.data() as Map<String, dynamic>?;

          if (messageData != null &&
              messageData['text'] == "This message was deleted") {
            print('Message already marked as deleted: $messageId');
            continue;
          }

          if (messageData != null && messageData.containsKey('mediaUrl')) {
            String? mediaUrl = messageData['mediaUrl'];

            if (mediaUrl != null && mediaUrl.isNotEmpty) {
              FirebaseStorage.instance.refFromURL(mediaUrl).delete().then((_) {
                print('Media deleted from storage: $mediaUrl');
              }).catchError((error) {
                print('Error deleting media: $error');
              });
            }
          }

          await messageCollection.doc(messageId).update({
            'message': 'This message was deleted',
            'mediaUrl': null,
          }).then((_) {
            print('Message updated to: This message was deleted');
          }).catchError((error) {
            print('Error updating message: $error');
          });
        }
      } catch (e) {
        print('Error during message update: $e');
      }
    }
    selectedMessageIds.clear();
  }

  void updateBackgroundColor(BuildContext context) {
    primaryColor.value = Theme.of(context).colorScheme.secondary;
  }

  @override
  void onInit() {
    super.onInit();
    fetchAllUsers();
    updateBackgroundColor(Get.context!);
  }

  Future<void> deleteChat(String otherUserId) async {
    try {
      final currentUserId = _firebaseAuth.currentUser?.uid;
      if (currentUserId == null) {
        print("No current user found.");
        return;
      }

      final chatRoomId = getChatRoomId(currentUserId, otherUserId);

      final chatRoomMessagesSnapshot = await _firebaseFirestore
          .collection('chat_room')
          .doc(chatRoomId)
          .collection('message')
          .get();

      WriteBatch batch = _firebaseFirestore.batch();

      for (var doc in chatRoomMessagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      final remainingMessages = await _firebaseFirestore
          .collection('chat_room')
          .doc(chatRoomId)
          .collection('message')
          .get();

      if (remainingMessages.docs.isEmpty) {
        await _firebaseFirestore
            .collection('chat_room')
            .doc(chatRoomId)
            .delete();
        print("Chat room deleted successfully.");
      } else {
        print("Some messages still exist, chat room not deleted.");
      }

      // Remove the chat from the local state (if necessary)
      users.removeWhere((user) => user.uid == otherUserId);
      lastMessageData.removeWhere((key, value) => key.uid == otherUserId);

      print("Chat deleted successfully.");
    } catch (e) {
      print("Error deleting chat: $e");
    }
  }

  void changeSortOrder() {
    if (sortOrder.value == 'Newest') {
      sortOrder.value = "Oldest";
    } else {
      sortOrder.value = "Newest";
    }
    sortedUsers;
  }

  Future<void> fetchAllUsers() async {
    try {
      final currentUserId = _firebaseAuth.currentUser?.uid;
      if (currentUserId == null) {
        print("No current user ID found.");
        return;
      }

      final chatRoomsSnapshot =
          await _firebaseFirestore.collection('chat_room').get();

      final userIdsWithChats = <String>{};

      for (var doc in chatRoomsSnapshot.docs) {
        final chatRoomId = doc.id;

        if (chatRoomId.contains(currentUserId)) {
          final parts = chatRoomId.split('_');
          if (parts.length == 2) {
            final firstUserId = parts[0];
            final secondUserId = parts[1];

            if (firstUserId != currentUserId) {
              userIdsWithChats.add(firstUserId);
            }
            if (secondUserId != currentUserId) {
              userIdsWithChats.add(secondUserId);
            }
          }
        }
      }

      if (userIdsWithChats.isEmpty) {
        print("No users with chats found.");
        isInitialized.value = true;
        return;
      }

      print("Found ${userIdsWithChats.length} unique users.");

      final usersWithChats = <UserModel>[];
      for (var userId in userIdsWithChats) {
        final userDoc =
            await _firebaseFirestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final user =
              UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
          usersWithChats.add(user);
          print("Fetched user: ${user.userName} with ID: $userId");
        } else {
          print("User document does not exist for ID: $userId");
        }
      }

      if (usersWithChats.isEmpty) {
        print("No users fetched.");
        return;
      }

      print("Fetched ${usersWithChats.length} users.");

      users.value = usersWithChats;

      fetchLastMessageData(usersWithChats);
    } catch (e) {
      print("Error fetching users with previous chats: $e");
    }
  }

  Future<void> fetchLastMessageData(List<UserModel> users) async {
    final newLastMessageData = <UserModel, LastMessageData>{};

    try {
      for (var user in users) {
        final chatRoomId =
            getChatRoomId(_firebaseAuth.currentUser?.uid, user.uid);
        print(chatRoomId);
        final snapshot = await _firebaseFirestore
            .collection('chat_room')
            .doc(chatRoomId)
            .collection('message')
            .orderBy('timeStamp', descending: true)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final messageData =
              snapshot.docs.first.data() as Map<String, dynamic>?;
          final timestamp = messageData?['timeStamp'];
          final lastMessage = messageData?['message'] ?? '';
          final senderId = messageData?['senderId'] ?? '';
          final lastMessageAt =
              (timestamp is Timestamp) ? timestamp.toDate() : DateTime.now();
          final count = await setupUnreadMessagesListenerPerUser(chatRoomId);

          if (count.isGreaterThan(0)) {
            unreadMessageCountPerUser.value++;
          }

          newLastMessageData[user] = LastMessageData(
            message: lastMessage,
            timestamp: lastMessageAt,
            senderId: senderId,
            count: count,
          );
        }
      }

      lastMessageData
        ..clear()
        ..addAll(newLastMessageData);
      isInitialized.value = true;
    } catch (e) {
      print("Error fetching last message data: $e");
    }
  }

  Future<int> setupUnreadMessagesListenerPerUser(String chatRoomId) async {
    final currentUserId = _firebaseAuth.currentUser?.uid;
    if (currentUserId == null) return 0;

    final snapshot = await FirebaseFirestore.instance
        .collection('chat_room')
        .doc(chatRoomId)
        .collection('message')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();
    print(snapshot.docs.length);

    return snapshot.docs.length;
  }

  Future<int> getUnreadMessageCount(String chatRoomId) async {
    final currentUserId = _firebaseAuth.currentUser?.uid;
    if (currentUserId == null) return 0;

    try {
      final snapshot = await _firebaseFirestore
          .collection('chat_room')
          .doc(chatRoomId)
          .collection('message')
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print("Error getting unread message count: $e");
      return 0;
    }
  }

  List<MapEntry<UserModel, LastMessageData?>> get sortedUsers {
    return lastMessageData.entries
        .where((entry) => entry.key.uid != _firebaseAuth.currentUser?.uid)
        .toList()
      ..sort((a, b) {
        final timestampA =
            a.value.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
        final timestampB =
            b.value.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);

        if (sortOrder.value == 'Newest') {
          return timestampB.compareTo(timestampA);
        } else {
          return timestampA.compareTo(timestampB);
        }
      });
  }

  Future<void> markMessagesAsRead(
      String currentUserId, String otherUserId) async {
    try {
      final chatRoomId = getChatRoomId(currentUserId, otherUserId);
      QuerySnapshot unreadMessages = await _firebaseFirestore
          .collection('chat_room')
          .doc(chatRoomId)
          .collection('message')
          .where('isRead', isEqualTo: false)
          .where('receiverId', isEqualTo: currentUserId)
          .get();

      WriteBatch batch = _firebaseFirestore.batch();

      for (QueryDocumentSnapshot doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      unreadMessageCountPerUser.value = 0;
      await batch.commit();
    } catch (e) {
      print("Error marking messages as read: $e");
    }
  }

  int getUnreadCountPerUser() {
    return unreadMessageCountPerUser.value;
  }

  String getChatRoomId(String? userId1, String? userId2) {
    List<String?> ids = [userId1, userId2];
    ids.sort();
    return ids.join("_");
  }

  Future<void> initializeChat(String userId, String otherUserId) async {
    chatRoomId = getChatRoomId(userId, otherUserId);
    if (isFriendStatus.value != 'loading') {
      listenToOtherUserTyping();
      isInitialized.value = true;
    }
  }

  void updateMessageState() {
    isMessageEmpty.value = messageController.text.isEmpty;
    if (messageController.text.isNotEmpty) {
      startTyping();
    } else {
      stopTyping();
    }
  }

  Future<String?> uploadMedia(File file, String chatId, bool isImage) async {
    String fileName = isImage
        ? 'image_${DateTime.now().millisecondsSinceEpoch}.png'
        : 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    Reference storageReference =
        FirebaseStorage.instance.ref().child('chats/$chatId/$fileName');

    UploadTask uploadTask = storageReference.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;

    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<String> _sendMessage(String chatRoomId, String receiverId,
      String? message, String? media) async {
    final String? currentUserId = _firebaseAuth.currentUser?.uid;
    final String? currentUserEmail = _firebaseAuth.currentUser?.email;
    final Timestamp timestamp = Timestamp.now();
    var id = const Uuid().v4();
    Message newMessage = Message(
        message: message,
        receiverId: receiverId,
        senderEmail: currentUserEmail ?? "No email",
        senderId: currentUserId ?? "No id",
        timeStamp: timestamp,
        isRead: false,
        mediaUrl: media,
        id: id);

    await _firebaseFirestore
        .collection('chat_room')
        .doc(chatRoomId)
        .collection('message')
        .doc(id)
        .set(newMessage.toMap());
    
    return id; // Return the message ID
  }

  Future<void> sendMessage(String text, String receiverId, BuildContext context,
      String currentUserName, String sendDeviceToken, String? media) async {
    messageController.clear();
    lastMessageId = await _sendMessage(chatRoomId, receiverId, text, media);
    isMessageEmpty.value = true;
    stopTyping();
    if (sendDeviceToken.isNotEmpty) {
      print(currentUserName);
      await NotificationsServices.sendNotificationToDevice(
          receiverId,context,currentUserName, text, );
    }
  }

  void startTyping() {
    updateTypingStatus(true, chatRoomId);
  }

  void stopTyping() {
    updateTypingStatus(false, chatRoomId);
  }

  void listenToOtherUserTyping() {
    listenToTypingStatus(chatRoomId, _firebaseAuth.currentUser?.uid ?? '')
        .listen((isTyping) {
      isOtherUserTyping.value = isTyping;
    });
  }

  Future<void> updateTypingStatus(bool isTyping, String chatRoomId) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final docRef = _firebaseFirestore.collection('chat_room').doc(chatRoomId);
      await docRef.set({'isTyping': isTyping, 'typingUser': user.uid},
          SetOptions(merge: true));
    }
  }

  Stream<bool> listenToTypingStatus(String chatRoomId, String userId) {
    return _firebaseFirestore
        .collection('chat_room')
        .doc(chatRoomId)
        .snapshots()
        .map((snapshot) {
      final typingUser = snapshot.data()?['typingUser'] ?? '';
      final isTyping = snapshot.data()?['isTyping'] ?? false;
      return isTyping && typingUser != userId;
    });
  }

  Stream<QuerySnapshot> getMessage(String chatRoomId) {
    return _firebaseFirestore
        .collection('chat_room')
        .doc(chatRoomId)
        .collection('message')
        .orderBy('timeStamp', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getUnreadMessages(String chatRoomId, String userId) {
    return _firebaseFirestore
        .collection('chat_room')
        .doc(chatRoomId)
        .collection('message')
        .where('isRead', isEqualTo: false)
        .where('receiverId', isEqualTo: userId)
        .snapshots();
  }

  Future<void> clearChatHistory(String chatRoomId) async {
    try {
      final String? currentUserId = _firebaseAuth.currentUser?.uid;
      if (currentUserId == null) return;

      // Get all messages in the chat room
      final messagesQuery = await _firebaseFirestore
          .collection('chat_room')
          .doc(chatRoomId)
          .collection('message')
          .get();

      // Update messages to mark them as cleared for the current user
      final batch = _firebaseFirestore.batch();
      
      for (var doc in messagesQuery.docs) {
        final messageData = doc.data();
        final senderId = messageData['senderId'] as String?;
        final receiverId = messageData['receiverId'] as String?;
        
        // Clear messages if current user is either sender or receiver
        if (senderId == currentUserId || receiverId == currentUserId) {
          batch.update(doc.reference, {
            'clearedFor': FieldValue.arrayUnion([currentUserId]),
            'clearedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // Also clear custom offers and delivery completions for the current user
      await _clearNotificationsForUser(chatRoomId, currentUserId);

      await batch.commit();
      
      // Force refresh the chat streams
      await _refreshChatStreams();
      
      print('Chat history cleared for user: $currentUserId');
    } catch (e) {
      print('Error clearing chat history: $e');
    }
  }

  Future<void> _refreshChatStreams() async {
    // Force refresh by temporarily setting initialized to false and back to true
    isInitialized.value = false;
    await Future.delayed(const Duration(milliseconds: 200));
    isInitialized.value = true;
  }

  Future<void> _clearNotificationsForUser(String chatRoomId, String userId) async {
    try {
      // Clear custom offers
      final offersQuery = await _firebaseFirestore
          .collection('chat_room')
          .doc(chatRoomId)
          .collection('custom_offers')
          .get();

      final batch = _firebaseFirestore.batch();
      
      for (var doc in offersQuery.docs) {
        final offerData = doc.data();
        final providerId = offerData['providerId'] as String?;
        final clientId = offerData['clientId'] as String?;
        
        // Clear offers if current user is either provider or client
        if (providerId == userId || clientId == userId) {
          batch.update(doc.reference, {
            'clearedFor': FieldValue.arrayUnion([userId]),
            'clearedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // Clear delivery completions
      final deliveriesQuery = await _firebaseFirestore
          .collection('chat_room')
          .doc(chatRoomId)
          .collection('delivery_completions')
          .get();

      for (var doc in deliveriesQuery.docs) {
        final deliveryData = doc.data();
        final providerId = deliveryData['providerId'] as String?;
        final clientId = deliveryData['clientId'] as String?;
        
        // Clear deliveries if current user is either provider or client
        if (providerId == userId || clientId == userId) {
          batch.update(doc.reference, {
            'clearedFor': FieldValue.arrayUnion([userId]),
            'clearedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
      print('Notifications cleared for user: $userId');
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }
}
