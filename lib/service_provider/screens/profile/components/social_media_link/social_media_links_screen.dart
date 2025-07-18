import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';
import 'package:pests247/client/widgets/custom_text_field.dart';
import 'package:pests247/client/widgets/custom_button.dart';

import '../../../../controllers/profile/social_media_controller.dart';

class SocialMediaLinksScreen extends StatelessWidget {
  const SocialMediaLinksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SocialMediaController socialMediaController = Get.put(SocialMediaController());
    final UserController userController = Get.find();

    // Initialize social media data
    socialMediaController.setSocialMediaInfo(
      facebook: userController.userModel.value!.companyInfo?.facebookLink ?? '',
      twitter: userController.userModel.value!.companyInfo?.twitterLink ?? '',
      links: userController.userModel.value!.companyInfo?.website ?? '',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Social Media & Links',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Social Media Section
              const Text(
                'Social Media',
                style: TextStyle(color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Add links to your company’s social media profiles.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 10),

              // Descriptive Text for Facebook
              const Text(
                'Enter your company’s Facebook page link.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              buildTextField(
                prefixIcon: FontAwesomeIcons.facebook,
                controller: socialMediaController.facebookController,
                labelText: '',
                onChanged: (value) {
                  socialMediaController.facebook.value = value;
                },
              ),
              const SizedBox(height: 10),

              // Descriptive Text for Twitter
              const Text(
                'Enter your company’s Twitter handle or page link.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              buildTextField(
                prefixIcon: FontAwesomeIcons.twitter,
                controller: socialMediaController.twitterController,
                labelText: '',
                onChanged: (value) {
                  socialMediaController.twitter.value = value;
                },
              ),
              const SizedBox(height: 20),

              // Links Section
              const Text(
                'Links',
                style: TextStyle(color: Colors.blue, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Add other relevant links for your company, like a website or blog.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 10),

              // Descriptive Text for Other Links
              const Text(
                'Enter any additional relevant links for your company.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              buildTextField(
                prefixIcon: FontAwesomeIcons.webflow,
                controller: socialMediaController.linksController,
                labelText: '',
                onChanged: (value) {
                  socialMediaController.links.value = value;
                },
              ),
              const SizedBox(height: 60),

              // Save Button
              Obx(() {
                return CustomButton(
                  height: 45,
                  text: 'Save',
                  textStyle: const TextStyle(fontSize: 15,color: Colors.white),
                  onPressed: socialMediaController.isChanged
                      ? () {
                    socialMediaController.updateSocialMediaInfo();
                  }
                      : () {},
                  isLoading: socialMediaController.isLoading.value,
                  backgroundColor: socialMediaController.isChanged ? Colors.blue : Colors.grey,
                  tag: '',
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
