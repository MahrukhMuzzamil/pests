import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pests247/service_provider/screens/profile/components/card_management/card_details_screen.dart';
import 'package:pests247/service_provider/screens/profile/components/change_password/change_password_screen.dart';
import 'package:pests247/service_provider/screens/profile/components/company_info/company_info_screen.dart';
import 'package:pests247/service_provider/screens/profile/components/credits/credits_screen.dart';
import 'package:pests247/service_provider/screens/profile/components/delete_account/delete_account_screen.dart';
import 'package:pests247/service_provider/screens/profile/components/question_answer/question_answer_screen.dart';
import 'package:pests247/service_provider/screens/profile/components/social_media_link/social_media_links_screen.dart';
import 'package:pests247/service_provider/screens/profile/components/support/support_screen.dart';
import '../../../client/widgets/custom_icon_button.dart';
import 'components/communication/email_template_screen.dart';
import 'components/communication/sms_template_screen.dart';
import 'components/gigs/manage_gigs_screen.dart';
import 'components/widgets/setting_tile.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool isNotification = true;
  bool isDownloadAll = true;
  //same func overridetr

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
            SettingTile(
              leadingIcon: const Icon(FontAwesomeIcons.lock),
              title: 'Password',
              subtitle: 'Update your account password',
              onTap: () {
                Get.to(() => const ChangePasswordScreen(),
                    transition: Transition.cupertino);
              },
            ),
            SettingTile(
              leadingIcon: const Icon(Icons.question_answer),
              title: 'Q&As',
              subtitle: 'Update your account question & answers',
              onTap: () {
                Get.to(() => const QuestionAnswerScreen(),
                    transition: Transition.cupertino);
              },
            ),
            const SizedBox(height: 10,),
            //billing and credits
            _buildSectionHeader('Credits'),
            SettingTile(
              leadingIcon: const Icon(FontAwesomeIcons.solidMoneyBill1),
              title: 'My Credits',
              subtitle: 'Manage and purchase credits for customer contact.',
              onTap: () {
                Get.to(() => const CreditsHistoryScreen(),
                    transition: Transition.cupertino);
              },
            ),
            // SettingTile(
            //   leadingIcon: const Icon(FontAwesomeIcons.creditCard),
            //   title: 'My payment details',
            //   subtitle: 'Manage your card details.',
            //   onTap: () {
            //     Get.to(() => const CardDetailsScreen(),
            //         transition: Transition.cupertino);
            //   },
            // ),
            //settings will be changed here





            //communication section
            const SizedBox(height: 10,),
            _buildSectionHeader('Communication'),
            SettingTile(
              leadingIcon: const Icon(FontAwesomeIcons.commentDots),
              title: 'SMS Template',
              subtitle: 'Update your SMS message template here.',
              onTap: () {
                Get.to(() => const SmsTemplateScreen(), transition: Transition.cupertino);
              },
            ),

            SettingTile(
              leadingIcon: const Icon(Icons.email),
              title: 'Email Template',
              subtitle: 'Update your email message template here.',
              onTap: () {
                Get.to(() => const EmailTemplateScreen(), transition: Transition.cupertino);
              },
            ),

            // Business Info Section
            const SizedBox(height: 10,),
            _buildSectionHeader('Business Info'),
            SettingTile(
              leadingIcon: const Icon(FontAwesomeIcons.businessTime),
              title: 'Company Info',
              subtitle: 'Set up your company info here',
              onTap: () {
                Get.to(() => const CompanyInfoScreen(),
                    transition: Transition.cupertino);
              },
            ),
            SettingTile(
              leadingIcon: const Icon(Icons.link),
              title: 'Social Media',
              subtitle: 'Set up your company social media',
              onTap: () {
                Get.to(() => const SocialMediaLinksScreen(),
                    transition: Transition.cupertino);
              },
            ),

            SettingTile(
              leadingIcon: const Icon(Icons.work),
              title: 'Manage Gigs',
              subtitle: 'Create and manage your service gigs',
              onTap: () {
                Get.to(() => const ManageGigsScreen(),
                    transition: Transition.cupertino);
              },
            ),

            // Support Section
            _buildSectionHeader('Support'),
            SettingTile(
              leadingIcon: const Icon(Icons.support_agent_rounded),
              title: 'Support',
              subtitle: 'Need any help? Get in touch with support.',
              onTap: () {
                Get.to(() => const SupportScreen(),
                    transition: Transition.cupertino);
              },
            ),
            SettingTile(
              leadingIcon: const Icon(Icons.delete),
              title: 'Delete Account',
              subtitle: 'Delete your account and its data',
              onTap: () {
                Get.to(() => const DeleteAccountScreen(),
                    transition: Transition.cupertino);
              },
            ),
            const SizedBox(height: 30,)
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
        style:  TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.blue.withOpacity(.8),
        ),
      ),
    );
  }
}
