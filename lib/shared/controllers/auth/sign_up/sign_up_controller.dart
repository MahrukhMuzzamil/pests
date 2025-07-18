import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/service_provider/models/question_answers/question_answers_model.dart';
import '../../../../client/screens/auth/verify_email/verify_email.dart';
import '../../../../client/widgets/custom_snackbar.dart';
import '../../../models/user/user_model.dart';

class SignUpController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();
  var question1 = 'What do you love most about your job?'.obs;
  var answer1 = ''.obs;
  var question2 = 'What inspired you to start your own business?'.obs;
  var answer2 = ''.obs;
  var question3 = 'Why should our clients choose you?'.obs;
  var answer3 = ''.obs;
  var question4 =
      'What changes have you made to keep your customers safe from Covid-19'
          .obs;
  var answer4 = ''.obs;

  var obscureText = true.obs;
  var tickMark = false.obs;
  var isLoading = false.obs;

  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }

  Future<void> registerUser(String accountType) async {
    isLoading.value = true;
    try {
      final UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );

      final User? user = userCredential.user;
      if (user != null) {
        UserModel userModel = UserModel(
          accountType: accountType,
          uid: user.uid,
          userName: '${firstNameController.text} ${lastNameController.text}',
          email: emailController.text.trim(),
          deviceToken: '',
          profilePicUrl: '',
          country: 'US',
          questionAnswerForm: QuestionAnswerForm(
            question1: question1.value,
            question2: question2.value,
            question3: question3.value,
            question4: question4.value,
            answer1: answer1.value,
            answer2: answer2.value,
            answer3: answer3.value,
            answer4: answer4.value,
          ),
          credits: 30,
          phone: phoneController.text,
          lastSeen: DateTime.now(),
          leadLocations: [],
          emailTemplate: '',
          smsTemplate: '',
          reviews: [],
          cardExpiry: '',
          cardNumber: '',
          creditHistoryList: [],
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userModel.toJson());
        await user.sendEmailVerification();
        Get.off(VerifyEmailPage(email: emailController.text),transition: Transition.cupertino);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        CustomSnackbar.showSnackBar(
          'Error',
          'The email address is already in use by another account.',
          const Icon(Icons.error, color: Colors.red),
          Colors.red,
          Get.context!, // Pass the context here
        );
      } else if (e.code == 'invalid-email') {
        CustomSnackbar.showSnackBar(
          'Error',
          'The email address is not valid.',
          const Icon(Icons.error, color: Colors.red),
          Colors.red,
          Get.context!,
        );
      } else {
        CustomSnackbar.showSnackBar(
          'Error',
          'An error occurred: ${e.message}',
          const Icon(Icons.error, color: Colors.red),
          Colors.red,
          Get.context!,
        );
      }
    } catch (e) {
      CustomSnackbar.showSnackBar(
        'Error',
        'An unexpected error occurred. Please try again.',
        const Icon(Icons.error, color: Colors.red),
        Colors.red,
        Get.context!,
      );
    } finally {
      isLoading.value = false;
    }
  }

}
