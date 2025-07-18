import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends GetxController{
  static Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLoggedIn") ?? false;
  }

  static Future<String?> getAccountType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("accountType");
  }

  static void setAccountType(String accountType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("accountType",accountType);
  }
}