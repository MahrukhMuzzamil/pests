import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconly/iconly.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';
import 'package:pests247/client/screens/posted_leads/posted_leads_screen.dart';
import 'package:pests247/client/screens/profile/profile_view.dart';
import 'package:pests247/client/screens/user_chats/chat.dart';
import 'package:pests247/shared/controllers/app/app_controller.dart';
import 'home/home.dart';
import 'business_listings_screen.dart';

class ClientBottomNavBar extends StatefulWidget {
  const ClientBottomNavBar({super.key});

  @override
  State<ClientBottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<ClientBottomNavBar> {
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
    const HomePage(),
    const ClientBusinessListingsScreen(),
    const Chat(),
    const PostedLeadsScreen(),
    const ClientProfileView(),
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
          padding: const EdgeInsets.all(8.0),
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
