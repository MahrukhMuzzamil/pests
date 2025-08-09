import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconly/iconly.dart';
import 'package:pests247/client/screens/posted_leads/posted_leads_screen.dart';
import 'package:pests247/client/screens/profile/profile_view.dart';
import 'package:pests247/client/screens/user_chats/chat.dart';
import 'package:pests247/shared/controllers/app/app_controller.dart';
import 'home/home.dart';

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
    const Chat(),
    const PostedLeadsScreen(),
    const ClientProfileView(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: isLoggedIn
          ? Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
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
                GButton(icon: IconlyBold.home, text: MediaQuery.of(context).size.width > 360 ? 'Home' : ''),
                GButton(icon: IconlyBold.chat, text: MediaQuery.of(context).size.width > 360 ? 'Chats' : ''),
                GButton(icon: IconlyBold.folder, text: MediaQuery.of(context).size.width > 360 ? 'Leads' : ''),
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
