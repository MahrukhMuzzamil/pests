import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pests247/client/screens/auth/sign_up/sign_up_page.dart';
import 'package:pests247/client/screens/client_bottom_nav_bar.dart';
import 'package:pests247/service_provider/screens/service_provider_bottom_nav_bar.dart';
import 'package:pests247/shared/controllers/app/app_controller.dart';

import '../../../client/widgets/custom_snackbar.dart';

class FirstAccountSelectionScreen extends StatefulWidget {
  const FirstAccountSelectionScreen({super.key});

  @override
  FirstAccountSelectionScreenState createState() =>
      FirstAccountSelectionScreenState();
}

class FirstAccountSelectionScreenState
    extends State<FirstAccountSelectionScreen> {
  FirstAccountSelectionScreenState();

  int selectedAccountIndex = -1;

  void selectAccount(int index) {
    setState(() {
      selectedAccountIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const Text(
            'Pests 247',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 35,
              color: Colors.blue,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'Please choose an account',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          _buildAccountContainer(
            index: 0,
            imagePath: 'assets/images/client.png',
            title: 'Client',
          ),
          const SizedBox(height: 50),
          _buildAccountContainer(
            index: 1,
            imagePath: 'assets/images/service_provider.png',
            title: 'Service Provider',
          ),
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Hero(
              tag: 'button',
              child: ElevatedButton(
                onPressed: () async {
                  if (selectedAccountIndex != -1) {
                    String accountType = selectedAccountIndex == 0
                        ? 'client'
                        : 'serviceProvider';
                    if(accountType == 'client')
                      {
                        Get.to(
                              () => const ClientBottomNavBar(),
                          transition: Transition.cupertino,
                        );
                      }
                    else{
                      Get.to(
                            () => const ServiceProviderBottomNavBar(),
                        transition: Transition.cupertino,
                      );
                    }
                  } else {
                    CustomSnackbar.showSnackBar(
                      'Error',
                      'Please choose an account',
                      const Icon(Icons.error, color: Colors.red),
                      Colors.red,
                      context,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(
                  'N E X T',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountContainer({
    required int index,
    required String imagePath,
    required String title,
  }) {
    bool isSelected = index == selectedAccountIndex;
    return GestureDetector(
      onTap: () => selectAccount(index),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.black.withOpacity(0.1),
            width: isSelected ? 1 : 0.5,
          ),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 25),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
