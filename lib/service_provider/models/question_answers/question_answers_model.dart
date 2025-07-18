class QuestionAnswerForm {
  final String? question1;
  final String? answer1;
  final String? question2;
  final String? answer2;
  final String? question3;
  final String? answer3;
  final String? question4;
  final String? answer4;

  QuestionAnswerForm({
    this.question1,
    this.answer1,
    this.question2,
    this.answer2,
    this.question3,
    this.answer3,
    this.question4,
    this.answer4,
  });

  // Convert QuestionAnswerForm object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'question1': question1,
      'answer1': answer1,
      'question2': question2,
      'answer2': answer2,
      'question3': question3,
      'answer3': answer3,
      'question4': question4,
      'answer4': answer4,
    };
  }

  // Create a QuestionAnswerForm object from Firestore data
  factory QuestionAnswerForm.fromMap(Map<String, dynamic> map) {
    return QuestionAnswerForm(
      question1: map['question1'] as String?,
      answer1: map['answer1'] as String?,
      question2: map['question2'] as String?,
      answer2: map['answer2'] as String?,
      question3: map['question3'] as String?,
      answer3: map['answer3'] as String?,
      question4: map['question4'] as String?,
      answer4: map['answer4'] as String?,
    );
  }
}
