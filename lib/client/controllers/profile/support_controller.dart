import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ClientSupportController extends GetxController {
  var email = ''.obs;
  var phoneNumber = ''.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSupportData();
  }

  Future<void> fetchSupportData() async {
    try {
      isLoading.value = true;
      final snapshot = await FirebaseFirestore.instance.collection('support').doc('contact').get();
      email.value = snapshot['email'] ?? '';
      phoneNumber.value = snapshot['phoneNumber'] ?? '';
    } catch (error) {
      print("Error fetching support data: $error");
    } finally {
      isLoading.value = false;
    }
  }
}
