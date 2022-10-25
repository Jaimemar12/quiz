import 'package:quiz/main.dart';

import 'APIHandler.dart';
import 'Display.dart';
import 'Exceptions.dart';
import 'Question.dart';

class Quiz {
  Future<List<Question>> _questions = Future(() => []);

  Quiz() {
    _startQuiz();
  }

  get questions => _questions;

  void _startQuiz() async {
    _questions = APIHandler.getQuestions(LoginData().username, LoginData().pin);
  }

  dynamic verifyAnswer(dynamic prompt, Type requiredType, [int? questionRange]){
    bool repeat = false;
    String answer = "";
    do{
      try{
        if (prompt.runtimeType == String){
          print(prompt);
        } else {
          Display.displayQuestion(prompt);
        }

        if (answer.trim().isEmpty) {
          throw NotANumberException('No response given');
        } else if(requiredType == int &&  int.tryParse(answer) == null) {
          throw NotANumberException('Not an integer');
        }

        if (questionRange != null && (int.parse(answer) > questionRange || int.parse(answer) < 1)) {
          throw OutOfBoundsException('Number is not inside of the range');
        }

        if (requiredType == int) {
          return int.parse(answer);
        }

        return answer;
      } on NotANumberException catch (bug){
        print('${bug.error}\n');
      } on OutOfBoundsException catch (bug){
        print('${bug.error}\n');
      }
    } while(!repeat);
  }
}