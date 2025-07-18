import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';
import 'package:pests247/client/controllers/user_chat/chats_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../client/screens/user_chats/chat_screen.dart';
import '../../../../../shared/models/lead_model/lead_model.dart';
import '../../../../../shared/models/user/user_model.dart';

Widget buildContacts(
    BuildContext context, LeadModel lead, UserModel userModel) {
  final UserController userController = Get.find<UserController>();
  return Card(
    elevation: 8,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Icon(Icons.phone,
                  color: Theme.of(context).colorScheme.primary, size: 30),
            ),
            title: const Text(
              'Give them a call',
              style: TextStyle(
                fontWeight: FontWeight.w200,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              'Call them directly',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.4),
              ),
            ),
            onTap: () async {
              final Uri launchUri = Uri(
                scheme: 'tel',
                path: userModel.phone,
              );
              await _launchUrl(launchUri);
            },
          ),
          _buildDivider(),
          ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Icon(Icons.message,
                  color: Theme.of(context).colorScheme.primary, size: 30),
            ),
            title: const Text(
              'Send a Message',
              style: TextStyle(
                fontWeight: FontWeight.w200,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              'Send an in-app message',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.4),
              ),
            ),
            onTap: () {
              Get.to(() => ChatScreen(userModel: userModel));
              ChatController chatController = Get.find();
              chatController.fetchAllUsers();
            },
          ),
          _buildDivider(),
          ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Icon(FontAwesomeIcons.whatsapp,
                  color: Theme.of(context).colorScheme.primary, size: 30),
            ),
            subtitle: Text(
              'Contact on Whatsapp',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.4),
              ),
            ),
            title: const Text(
              'Send WhatsApp',
              style: TextStyle(
                fontWeight: FontWeight.w200,
                fontSize: 15,
              ),
            ),
            onTap: () async {
              final Uri launchUri = Uri(
                scheme: 'https',
                host: 'wa.me',
                path: userModel.phone,
              );
              await _launchUrl(launchUri);
            },
          ),
          _buildDivider(),
          ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Icon(Icons.email,
                  color: Theme.of(context).colorScheme.primary, size: 30),
            ),
            title: const Text(
              'Send an Email',
              style: TextStyle(
                fontWeight: FontWeight.w200,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              'Send email using custom template',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.4),
              ),
            ),
            onTap: () async {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: userModel.email,
                query:
                    'subject=Pest Control Service&body=${userController.userModel.value!.emailTemplate ??= "Hi i found your request at Pests 247"}', // Optional
              );
              await _launchUrl(emailUri);
            },
          ),
          _buildDivider(),
          ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Icon(Icons.sms,
                  color: Theme.of(context).colorScheme.primary, size: 30),
            ),
            subtitle: Text(
              'Send SMS using custom template',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.4),
              ),
            ),
            title: const Text(
              'Send an SMS',
              style: TextStyle(
                fontWeight: FontWeight.w200,
                fontSize: 15,
              ),
            ),
            onTap: () async {
              final Uri smsUri = Uri(
                scheme: 'sms',
                path: userModel.phone,
                queryParameters: {
                  'body': userController.userModel.value!.smsTemplate,
                },
              );
              await _launchUrl(smsUri);
            },
          ),
        ],
      ),
    ),
  );
}

// Helper method to build a custom divider
Widget _buildDivider() {
  return SizedBox(
    height: 15,
    child: Divider(
      thickness: 1.5,
      color: Colors.grey.withOpacity(0.3),
      height: 0,
    ),
  );
}

// Helper method to launch URLs
Future<void> _launchUrl(Uri uri) async {
  if (!await launchUrl(uri)) {
    throw 'Could not launch $uri';
  }
}
