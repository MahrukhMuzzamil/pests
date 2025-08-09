import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:pests247/client/screens/profile/components/about/user_info_screen.dart';
import 'package:pests247/client/screens/profile/components/change_password/change_password_screen.dart';
import 'package:pests247/client/screens/profile/components/delete_account/delete_account_screen.dart';
import 'package:pests247/client/screens/profile/components/support/support_screen.dart';
// removed unused service_provider imports
import '../../../client/widgets/custom_icon_button.dart';
import '../../controllers/home/home_controller.dart';
import 'components/widgets/setting_tile.dart';

class ClientSettingsView extends StatefulWidget {
  const ClientSettingsView({super.key});

  @override
  State<ClientSettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<ClientSettingsView> {
  bool isNotification = true;
  bool isDownloadAll = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomIconButton(
            color: Colors.blue.withOpacity(0.14),
            icon: FontAwesomeIcons.arrowLeft,
            onTap: () {
              Get.back<void>();
            },
          ),
        ),
        centerTitle: true,
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            // Account Settings Section
            _buildSectionHeader('Account'),
            ClientSettingTile(
              leadingIcon: const Icon(Icons.privacy_tip_outlined),
              title: 'Privacy Policy',
              subtitle: 'How we handle your data',
              onTap: () {
                Get.to(() => const _StaticPolicyScreen(
                      title: 'Privacy Policy',
                      assetPath: 'assets/policies/privacy.md',
                    ));
              },
            ),
            ClientSettingTile(
              leadingIcon: const Icon(Icons.description_outlined),
              title: 'Terms of Service',
              subtitle: 'Your agreement with us',
              onTap: () {
                Get.to(() => const _StaticPolicyScreen(
                      title: 'Terms of Service',
                      assetPath: 'assets/policies/tos.md',
                    ));
              },
            ),
            ClientSettingTile(
              leadingIcon: const Icon(Icons.privacy_tip_outlined),
              title: 'Privacy Policy',
              subtitle: 'How we handle your data',
              onTap: () {
                Get.to(() => const _StaticPolicyScreen(
                      title: 'Privacy Policy',
                      assetPath: 'assets/policies/privacy.md',
                    ));
              },
            ),
            ClientSettingTile(
              leadingIcon: const Icon(Icons.description_outlined),
              title: 'Terms of Service',
              subtitle: 'Your agreement with us',
              onTap: () {
                Get.to(() => const _StaticPolicyScreen(
                      title: 'Terms of Service',
                      assetPath: 'assets/policies/tos.md',
                    ));
              },
            ),
            ClientSettingTile(
              leadingIcon: const Icon(FontAwesomeIcons.user),
              title: 'About',
              subtitle: 'Update your info here',
              onTap: () {
                Get.to(() => const ClientUserInfoScreen(),
                    transition: Transition.cupertino);
              },
            ),
            ClientSettingTile(
              leadingIcon: const Icon(FontAwesomeIcons.lock),
              title: 'Password',
              subtitle: 'Update your account password',
              onTap: () {
                Get.to(() => const ClientChangePasswordScreen(),
                    transition: Transition.cupertino);
              },
            ),
            const SizedBox(
              height: 10,
            ),

            // Support Section
            _buildSectionHeader('Support'),
            ClientSettingTile(
              leadingIcon: const Icon(Icons.support_agent_rounded),
              title: 'Support',
              subtitle: 'Need any help? Get in touch with support.',
              onTap: () {
                Get.to(() => const ClientSupportScreen(),
                    transition: Transition.cupertino);
              },
            ),
            ClientSettingTile(
              leadingIcon: const Icon(Icons.delete),
              title: 'Delete Account',
              subtitle: 'Delete your account and its data',
              onTap: () {
                Get.to(() => const ClientDeleteAccountScreen(),
                    transition: Transition.cupertino);
              },
            ),
            ClientSettingTile(
              leadingIcon: const Icon(IconlyBold.logout),
              title: 'Log Out',
              subtitle: 'Log out from current account',
              onTap: () {
                final HomeController homeController = Get.find();
                homeController.logoutUser();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.blue.withOpacity(.8),
        ),
      ),
    );
  }
}

class _StaticPolicyScreen extends StatelessWidget {
  final String title;
  final String assetPath;
  const _StaticPolicyScreen({required this.title, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<String>(
        future: DefaultAssetBundle.of(context).loadString(assetPath),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(snapshot.data ?? ''),
          );
        },
      ),
    );
  }
}
