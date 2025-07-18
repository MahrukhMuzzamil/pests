import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:get/get.dart';
import '../../../../shared/controllers/auth/sign_up/sign_up_controller.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../../widgets/custom_text_field.dart';

class SignupPage extends StatelessWidget {
  final String accountType;

  const SignupPage({super.key, required this.accountType});

  @override
  Widget build(BuildContext context) {
    final SignUpController controller = Get.put(SignUpController());
    final mediaQuerySize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          child: Form(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Welcome to a Pest-Free Environment",
                      style: GoogleFonts.actor(
                        fontSize: mediaQuerySize.width * 0.065,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  SizedBox(height: mediaQuerySize.width * 0.06),
                  buildTextField(
                    controller: controller.firstNameController,
                    labelText: 'First Name',
                    prefixIcon: CupertinoIcons.person,
                  ),
                  SizedBox(height: mediaQuerySize.width * 0.06),
                  buildTextField(
                    controller: controller.lastNameController,
                    labelText: 'Last Name',
                    prefixIcon: CupertinoIcons.person,
                  ),
                  SizedBox(height: mediaQuerySize.width * 0.06),
                  buildTextField(
                    controller: controller.emailController,
                    labelText: 'Email',
                    prefixIcon: Icons.email_outlined,
                  ),
                  SizedBox(height: mediaQuerySize.width * 0.06),
                  buildTextField(
                    maxLines: 1,
                    controller: controller.passController,
                    labelText: 'Password',
                    prefixIcon: CupertinoIcons.lock,
                    obscureText: controller.obscureText.value,
                    suffixIcon: GestureDetector(
                      onTap: controller.toggleObscureText,
                      child: Icon(
                        controller.obscureText.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: mediaQuerySize.width * 0.06),
                  buildTextField(
                    maxLines: 1,
                    controller: controller.confirmPassController,
                    labelText: 'Confirm Password',
                    prefixIcon: CupertinoIcons.lock,
                    obscureText: controller.obscureText.value,
                  ),
                  SizedBox(height: mediaQuerySize.width * 0.06),
                  buildPhoneField(controller),
                  SizedBox(height: mediaQuerySize.width * 0.06),
                  buildTermsAndConditions(controller),
                  SizedBox(height: mediaQuerySize.width * 0.07),
                  CustomButton(
                    height: 50,
                    textStyle:
                        const TextStyle(fontSize: 16, color: Colors.white),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    text: "Create Account",
                    onPressed: () {
                      if (controller.firstNameController.text.isEmpty ||
                          controller.lastNameController.text.isEmpty ||
                          controller.emailController.text.isEmpty ||
                          controller.passController.text.isEmpty ||
                          controller.phoneController.text.isEmpty ||
                          controller.confirmPassController.text.isEmpty) {
                        CustomSnackbar.showSnackBar(
                          'Error',
                          'Please enter all details.',
                          const Icon(Icons.error, color: Colors.red),
                          Colors.red,
                          context,
                        );
                        // Show error dialog
                      } else if (!controller.tickMark.value) {
                        // Show error dialog
                        CustomSnackbar.showSnackBar(
                          'Error',
                          'Please agree to terms and conditions',
                          const Icon(Icons.error, color: Colors.red),
                          Colors.red,
                          context,
                        );
                      } else if (controller.passController.text.length < 8) {
                        // Show error dialog
                        CustomSnackbar.showSnackBar(
                          'Error',
                          'Please enter a strong code with at least 8 digits.',
                          const Icon(Icons.error, color: Colors.red),
                          Colors.red,
                          context,
                        );
                      } else {
                        controller.registerUser(accountType);
                      }
                    },
                    isLoading: controller.isLoading.value,
                    tag: 'ButtonL O G I N',
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget buildPhoneField(SignUpController controller) {
    return SizedBox(
      height: 80,
      child: IntlPhoneField(
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black.withOpacity(.2)),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black.withOpacity(.7)),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          labelText: 'Phone Number',
        ),
        initialCountryCode: 'US',
        onChanged: (phone) {
          controller.phoneController.text = phone.completeNumber;
        },
      ),
    );
  }

  Widget buildTermsAndConditions(SignUpController controller) {
    return GestureDetector(
      onTap: () {
        controller.tickMark.value = !controller.tickMark.value;
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() => controller.tickMark.value
              ? const Icon(CupertinoIcons.check_mark)
              : const Icon(CupertinoIcons.square,
                  color: CupertinoColors.inactiveGray)),
          const Text(" I've read and agree to "),
          GestureDetector(
            onTap: () {
              // Navigate to Terms and Conditions page
            },
            child: const Text(
              "Terms & Conditions",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
