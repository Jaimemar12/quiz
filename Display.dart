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

  }
}