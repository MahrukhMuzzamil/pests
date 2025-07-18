import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pests247/client/controllers/user/user_controller.dart';
import 'package:pests247/client/widgets/custom_text_field.dart';

import '../../../../controllers/profile/question_answer_controller.dart';

class QuestionAnswerScreen extends StatelessWidget {
  const QuestionAnswerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final QuestionAnswerController controller = Get.put(
        QuestionAnswerController());
    final UserController userController = Get.find();

    controller.setQuestionAnswers(
        userController.userModel.value!.questionAnswerForm!.answer1!,
        userController.userModel.value!.questionAnswerForm!.answer2!,
        userController.userModel.value!.questionAnswerForm!.answer3!,
        userController.userModel.value!.questionAnswerForm!.answer4!);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Q&As', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Obx(() {
            return Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(.2),
                borderRadius: const BorderRadius.all(Radius.circular(25)),
              ),
              child: TextButton(
                onPressed: controller.detectChanges
                    ? () {
                  controller.saveAnswers();

                }
                    : null,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: controller.detectChanges
                        ? Colors.blue
                        : Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(
        () =>  controller.isLoading.value ? const Center(child: CircularProgressIndicator(strokeWidth: 7,),) : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Descriptive Text
                const Text(
                  'Question & Answers',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Answer some common questions upfront to remove customer reservations and provide clarity.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // Question 1
                Text(controller.question1.value,
                  style: const TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 10),
                buildTextField(
                  controller: controller.answer1Controller,
                  onChanged: (value) => controller.answer1.value = value,
                  labelText: '',
                ),
                const SizedBox(height: 30),

                // Question 2
                Text(controller.question2.value,
                  style: const TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 10),
                buildTextField(
                  controller: controller.answer2Controller,
                  onChanged: (value) => controller.answer2.value = value,
                  labelText: '',
                ),
                const SizedBox(height: 30),

                // Question 3
                Text(controller.question3.value,
                  style: const TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 10),
                buildTextField(
                  controller: controller.answer3Controller,
                  onChanged: (value) => controller.answer3.value = value,
                  labelText: '',
                ),
                const SizedBox(height: 30),

                // Question 4
                Text(controller.question4.value,
                  style: const TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 10),
                buildTextField(
                  controller: controller.answer4Controller,
                  onChanged: (value) => controller.answer4.value = value,
                  labelText: '',
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
