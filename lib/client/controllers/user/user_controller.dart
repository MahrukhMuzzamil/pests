import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pests247/shared/controllers/app/app_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/models/user/user_model.dart';

class UserController extends GetxController {
  Rxn<UserModel> userModel = Rxn<UserModel>();
  var isLoading = true.obs;

  void setUser(UserModel user) {
    userModel.value = user;
  }

  @override
  void onInit() {
    super.onInit();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      bool isLoggedIn = await AppController.checkLoginStatus();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("userId");

      isLoading.value = true;
      if(isLoggedIn && userModel.value == null)
        {
          DocumentSnapshot doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
          if (doc.exists) {
            // Enforce visibility expiry
            final data = doc.data() as Map<String, dynamic>;
            final dynamic expiryRaw = data['visibilityPackageExpiry'];
            DateTime? expiry;
            if (expiryRaw is Timestamp) {
              expiry = expiryRaw.toDate();
            } else if (expiryRaw is String) {
              try { expiry = DateTime.parse(expiryRaw); } catch (_) {}
            }

            if (expiry != null && DateTime.now().isAfter(expiry)) {
              final Map<String, dynamic> newCompanyInfo = Map<String, dynamic>.from(data['companyInfo'] ?? {});
              newCompanyInfo['premiumPackage'] = 0;
              await FirebaseFirestore.instance.collection('users').doc(userId).update({
                'companyInfo': newCompanyInfo,
                'visibilityPackage': null,
                'visibilityPackageName': null,
                'visibilityPackageExpiry': null,
              });
              data['companyInfo'] = newCompanyInfo;
              data['visibilityPackage'] = null;
              data['visibilityPackageName'] = null;
              data['visibilityPackageExpiry'] = null;
            }

            UserModel user = UserModel.fromJson(data);
            setUser(user);
          }
        }
    } catch (e) {
      print('Error fetching user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(user.toJson());
      setUser(user);
    } catch (e) {
      print('Error updating user: $e');
    }
  }

  String? get accountType {
    return userModel.value?.accountType;
  }

}
