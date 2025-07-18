import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';
import '../../../client/widgets/custom_snackbar.dart';
import '../../models/question_answers/question_answers_model.dart';

class QuestionAnswerController extends GetxController {
  var question1 = 'What do you love most about your job?'.obs;
  var answer1 = ''.obs;
  var question2 = 'What inspired you to start your own business?'.obs;
  var answer2 = ''.obs;
  var question3 = 'Why should our clients choose you?'.obs;
  var answer3 = ''.obs;
  var question4 = 'What changes have you made to keep your customers safe from Covid-19'.obs;
  var answer4 = ''.obs;

  var isChanged = false.obs;
  var isLoading = false.obs;

  final TextEditingController answer1Controller = TextEditingController();
  final TextEditingController answer2Controller = TextEditingController();
  final TextEditingController answer3Controller = TextEditingController();
  final TextEditingController answer4Controller = TextEditingController();
  final TextEditingController answer5Controller = TextEditingController();

  bool get detectChanges {
    final UserController userController = Get.find();

    return (userController.userModel.value!.questionAnswerForm!.answer1 !=
            answer1.value ||
        userController.userModel.value!.questionAnswerForm!.answer2 !=
            answer2.value ||
        userController.userModel.value!.questionAnswerForm!.answer3 !=
            answer3.value ||
        userController.userModel.value!.questionAnswerForm!.answer4 !=
            answer4.value);
  }

  void setQuestionAnswers(String answer1, String answer2, String answer3,
      String answer4) {
    answer1Controller.text = answer1;
    answer2Controller.text = answer2;
    answer3Controller.text = answer3;
    answer4Controller.text = answer4;

    this.answer1.value = answer1;
    this.answer2.value = answer2;
    this.answer3.value = answer3;
    this.answer4.value = answer4;

    isChanged.value = false;
  }

  void saveAnswers() {
    updateUserQuestionAnswers(
      question1.value,
      answer1Controller.text,
      question2.value,
      answer2Controller.text,
      question3.value,
      answer3Controller.text,
      question4.value,
      answer4Controller.text,
    );
  }

  @override
  void onClose() {
    answer1Controller.dispose();
    answer2Controller.dispose();
    answer3Controller.dispose();
    answer4Controller.dispose();
    answer5Controller.dispose();
    super.onClose();
  }

  void updateUserQuestionAnswers(
      String q1,
      String a1,
      String q2,
      String a2,
      String q3,
      String a3,
      String q4,
      String a4,
      ) async {
    isLoading.value = true;
    final UserController userController = Get.find();
    var userModel = userController.userModel;

    bool hasExceededLength = [a1, a2, a3, a4].any((answer) => answer.length > 200);

    if (hasExceededLength) {
      CustomSnackbar.showSnackBar(
        'Character Limit Exceeded',
        'Each answer must be 200 characters or less.',
        const Icon(Icons.warning, color: Colors.blueGrey),
        Colors.blueGrey.withOpacity(.3),
        Get.context!,
      );
      return;
    }

    // Check if no changes are made
    if (userModel.value?.questionAnswerForm?.toMap() ==
        {
          'question1': q1,
          'answer1': a1,
          'question2': q2,
          'answer2': a2,
          'question3': q3,
          'answer3': a3,
          'question4': q4,
          'answer4': a4,
        }) {
      isLoading.value = false;
      CustomSnackbar.showSnackBar(
        'No Changes',
        'No changes were made to the answers.',
        const Icon(Icons.warning, color: Colors.orange),
        Colors.orange,
        Get.context!,
      );
      return;
    }

    // Update the form with new answers
    userModel.value?.questionAnswerForm = QuestionAnswerForm(
      question1: q1,
      answer1: a1,
      question2: q2,
      answer2: a2,
      question3: q3,
      answer3: a3,
      question4: q4,
      answer4: a4,
    );

    // Save to Firestore and handle errors
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userModel.value?.uid)
          .update({
        'questionAnswerForm': userModel.value?.questionAnswerForm?.toMap()
      });

      await userController.fetchUser();
      setQuestionAnswers(
        answer1.value,
        answer2.value,
        answer3.value,
        answer4.value,
      );
      isLoading.value = false;
      CustomSnackbar.showSnackBar(
        'Success',
        'Your answers have been successfully updated!',
        const Icon(Icons.check_circle, color: Colors.green),
        Colors.green,
        Get.context!,
      );
    } catch (error) {
      isLoading.value = false;
      CustomSnackbar.showSnackBar(
        'Error',
        'Failed to update answers. Please try again later.',
        const Icon(Icons.error, color: Colors.red),
        Colors.red,
        Get.context!,
      );
    }
  }

}
