import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';
import 'package:pests247/client/widgets/custom_text_field.dart';

import '../../../../../client/widgets/custom_button.dart';
import '../../../../controllers/profile/user_info_controller.dart';

class UserInfoScreen extends StatelessWidget {
  const UserInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserInfoController profileController = Get.put(UserInfoController());
    UserController userController = Get.find();
    var userModel = userController.userModel.value;

    profileController.setUserInfo(userModel?.userName ?? '',
        userModel?.email ?? '',
        userModel?.phone ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile',style:  TextStyle(fontSize: 19,fontWeight: FontWeight.bold),),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Image
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue.withOpacity(.8),
                  child: userModel?.profilePicUrl == null
                      ? const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  )
                      : ClipOval(
                    child: Image.network(
                      userModel!.profilePicUrl!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'This name will be shown to users or leads for identification.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 10),

              buildTextField(
                controller: profileController.userNameController,
                onChanged: (value) {
                  profileController.userName.value = value;
                },
                labelText: '',
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 30),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your email will be used for login and notifications. This information will be private.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 10),

              buildTextField(
                controller: profileController.emailController,
                onChanged: (value) {
                  profileController.email.value = value;
                },
                labelText: '',
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: 30),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your contact number will be used for notifications and communication with leads.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 10),

              buildTextField(
                controller: profileController.phoneController,
                onChanged: (value) {
                  profileController.contactNumber.value = value;
                },
                labelText: '',
                prefixIcon: Icons.phone,
              ),
              const SizedBox(height: 50),

              Obx(() {
                return CustomButton(
                  height: 45,
                  text: 'Save',
                  tag: 'saveButton',
                  textStyle: const TextStyle(fontSize: 15,color: Colors.white),
                  onPressed: profileController.isChanged
                      ? () {
                    profileController.updateUserInfo();
                  }
                      : () {},
                  isLoading: profileController.isLoading.value,
                  backgroundColor: profileController.isChanged
                      ? Colors.blue
                      : Colors.grey,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
