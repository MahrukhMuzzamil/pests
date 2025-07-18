import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pests247/client/screens/on_board/start.dart';
import 'package:pests247/data/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'client/screens/client_bottom_nav_bar.dart';
import 'client/widgets/colors.dart';
import 'firebase_options.dart';
import 'service_provider/screens/service_provider_bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    await Keys.loadAllKeys();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

    runApp(MyApp(isLoggedIn: isLoggedIn));
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({required this.isLoggedIn, super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: FutureBuilder(
        future: checkLoginStatus(),
        builder: (context, loginSnapshot) {
          if (!isLoggedIn) {
            return const StartPage();
          } else {
            return FutureBuilder(
              future: getAccountType(),
              builder: (context, accountSnapshot) {
                if (accountSnapshot.hasData) {
                  String accountType = accountSnapshot.data ?? 'client';
                  if (accountType == 'serviceProvider') {
                    return const ServiceProviderBottomNavBar();
                  } else {
                    return const ClientBottomNavBar();
                  }
                } else {
                  return Container();
                }
              },
            );
          }
        },
      ),
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: CustomColors.greyColor.withOpacity(.2),
          primary: Colors.blueAccent,
          secondary: CustomColors.yellowSecondaryLight,
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          tertiary: Colors.black.withOpacity(.4),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: GoogleFonts.poppins().fontFamily,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: CustomColors.greyColor.withOpacity(.2),
          primary: CustomColors.yellowSecondaryLight,
          secondary: CustomColors.yellowSecondaryLight,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          tertiary: CustomColors.yellowSecondaryLight,
        ),
        useMaterial3: true,
        fontFamily: GoogleFonts.poppins().fontFamily,
        scaffoldBackgroundColor: CustomColors.blackprimaryDark,
        appBarTheme: AppBarTheme(
          backgroundColor: CustomColors.blackprimaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }

  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLoggedIn") ?? false;
  }

  Future<String?> getAccountType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("accountType");
  }
}
