import 'Question.dart';

class Display {
  static void displayQuestion(Question prompt) {
    String choices = "";
    int num = 1;
    if(prompt.choices.runtimeType != String){
      for (final element in prompt.choices){
        choices += '$num: $element\n';
        num++;
      }
    }
    print('${prompt.stem}\n$choices');
  }

  static void displayFeedback(List<Question> userQuestions) {
    if (userQuestions.isNotEmpty){
      int sum = 0;
      for(Question question in userQuestions){
        sum += question.score as int;
      }
      print('Total score is $sum/${userQuestions.length}');
    }
  }
}