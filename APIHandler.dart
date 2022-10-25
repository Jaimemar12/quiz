import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Question.dart';

abstract class APIHandler {


  static Future<List<Question>> getQuestions(String username, String pin) async {
    List<Question> questions = [];
    for (int i = 1; i < 16; i++) {
      String num;
      if (i < 10) {
        num = '0$i';
      } else {
        num = i.toString();
      }
      var url = Uri.parse('https://www.cs.utep.edu/cheon/cs4381/homework/quiz/get.php?user=$username&pin=$pin&quiz=quiz$num');
      var response = await http.get(url);
      var decoded = json.decode(response.body);
      if (decoded['response'].toString() == 'true') {
        decoded['quiz']['question'].forEach((element) {
          if(element['type'].toString() == '1') {
            questions.add(MultipleChoice(element['stem'], element['option'], element['answer']));
          } else if (element['type'].toString() == '2') {
            questions.add(FillInBlank(element['stem'], element['answer'][0]));
          }
        });
      }
    }

    return questions;
  }
}