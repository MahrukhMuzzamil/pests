import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../shared/controllers/auth/login/login_controller.dart';
import '../../../../client/screens/auth/forget_pass/forget_pass_screen.dart';
import '../../../../client/widgets/custom_button.dart';
import '../../../../client/widgets/custom_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuerySize = MediaQuery.of(context).size;
    final LoginController loginController = Get.put(LoginController());

    // List of images for the carousel slider
    final List<String> carouselImages = [
      'assets/login_icons/1.png',
      'assets/login_icons/2.png',
      'assets/login_icons/3.png',
      'assets/login_icons/4.png',
      'assets/login_icons/5.png',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      backgroundColor: CupertinoColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: mediaQuerySize.height * 0.23,
              child: CarouselSlider(
                options: CarouselOptions(
                  height: mediaQuerySize.height * 0.23,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 2),
                  autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                ),
                items: carouselImages.map((imagePath) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                      );
                    },
                  );
                }).toList(),
              )

            ),
            const SizedBox(height: 10),
            Column(
              children: [
                const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Row(children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Please sign in to continue',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                SizedBox(
                  width: mediaQuerySize.width * 0.91,
                  child: Form(
                    key: loginController.formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 90,
                          child: buildTextField(
                            prefixIcon: Icons.email,
                            controller: loginController.emailController,
                            labelText: 'Email',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Invalid email address';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: mediaQuerySize.width * 0.03),
                        SizedBox(
                          height: 90,
                          child: Obx(() => buildTextField(
                            maxLines: 1,
                            controller: loginController.passwordController,
                            obscureText: loginController.obscureText.value,
                            labelText: 'Password',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            prefixIcon: Icons.lock,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                loginController.toggleObscureText();
                              },
                              child: Icon(
                                loginController.obscureText.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                            ),
                          )),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (c) => const ResetPasswordPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: mediaQuerySize.width * 0.05),
                Obx(
                      () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    child: CustomButton(
                      text: "L O G I N",
                      tag: 'ButtonL O G I N',
                      onPressed: () {
                        if (loginController.formKey.currentState?.validate() ?? false) {
                          loginController.loginUser(context);
                        }
                      },
                      isLoading: loginController.isLoading.value,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      textColor: Colors.white,
                      icon: Icons.arrow_forward,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
