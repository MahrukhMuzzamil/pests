import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconly/iconly.dart';
import 'package:pests247/client/screens/user_chats/chat.dart';
import 'package:pests247/service_provider/screens/purchased_leads/purchased_leads_screen.dart';
import '../../client/controllers/user/user_controller.dart';
import '../../service_provider/screens/profile/profile_view.dart';
import '../../shared/controllers/app/app_controller.dart';
import 'leads/leads_screen.dart';
import 'job_alerts/job_alerts_screen.dart';

class ServiceProviderBottomNavBar extends StatefulWidget {
  const ServiceProviderBottomNavBar({super.key});

  @override
  State<ServiceProviderBottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<ServiceProviderBottomNavBar> {
  int _currentIndex = 0;
  bool isLoggedIn = false;
  late final UserController userController;

  @override
  void initState() {
    super.initState();
    userController = Get.isRegistered<UserController>()
        ? Get.find<UserController>()
        : Get.put(UserController());
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    bool status = await AppController.checkLoginStatus();
    setState(() {
      isLoggedIn = status;
    });
  }

  List<Widget> get _pages => [
        const LeadsScreen(),
        const Chat(),
        const PurchasedLeadsScreen(),
        // Job alerts requires provider coordinates. If unavailable, default to 0,0 which yields empty list.
        JobAlertsScreen(
          providerLatitude: userController.userModel.value?.companyInfo?.latitude ?? 0,
          providerLongitude: userController.userModel.value?.companyInfo?.longitude ?? 0,
        ),
        const ProfileView(),
      ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          final offsetAnim = Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
          final fadeAnim = CurvedAnimation(parent: animation, curve: Curves.easeOut);
          return FadeTransition(
            opacity: fadeAnim,
            child: SlideTransition(position: offsetAnim, child: child),
          );
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: isLoggedIn
          ? Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
          child: SafeArea(
            child: GNav(
              gap: 6,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              activeColor: Colors.white,
              iconSize: 24,
              tabBackgroundColor: Theme.of(context).colorScheme.primary,
              color: Colors.black,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              onTabChange: (value) {
                setState(() {
                  _currentIndex = value;
                });
              },
               tabs: [
                GButton(icon: IconlyBold.home, text: MediaQuery.of(context).size.width > 360 ? 'Leads' : ''),
                GButton(icon: IconlyBold.chat, text: MediaQuery.of(context).size.width > 360 ? 'Chats' : ''),
                GButton(icon: IconlyBold.folder, text: MediaQuery.of(context).size.width > 360 ? 'Purchased' : ''),
                 GButton(icon: IconlyBold.notification, text: MediaQuery.of(context).size.width > 360 ? 'Alerts' : ''),
                GButton(icon: IconlyBold.setting, text: MediaQuery.of(context).size.width > 360 ? 'Profile' : ''),
              ],
            ),
          ),
        ),
      )
          : const SizedBox.shrink(),
    );
  }
}
