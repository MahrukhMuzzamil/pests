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

class ServiceProviderBottomNavBar extends StatefulWidget {
  const ServiceProviderBottomNavBar({super.key});

  @override
  State<ServiceProviderBottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<ServiceProviderBottomNavBar> {
  int _currentIndex = 0;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    bool status = await AppController.checkLoginStatus();
    setState(() {
      isLoggedIn = status;
    });
  }

  final List<Widget> _pages = [
    const LeadsScreen(),
    const Chat(),
    const PurchasedLeadsScreen(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: isLoggedIn
          ? Container(
        color: Colors.white,
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
          child: SafeArea(
            child: GNav(
              gap: 8,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              activeColor: Colors.white,
              iconSize: 24,
              tabBackgroundColor: Colors.blue,
              color: Colors.black,
              onTabChange: (value) {
                setState(() {
                  _currentIndex = value;
                });
              },
              tabs: const [
                GButton(
                  icon: IconlyBold.home,
                  text: '',
                ),
                GButton(
                  icon: IconlyBold.chat,
                  text: '',
                ),
                GButton(
                  icon: IconlyBold.folder,
                  text: '',
                ),
                GButton(
                  icon: IconlyBold.setting,
                  text: '',
                ),
              ],
            ),
          ),
        ),
      )
          : const SizedBox.shrink(),
    );
  }
}
