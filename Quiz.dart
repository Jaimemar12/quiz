import 'dart:convert';

import 'package:quiz/main.dart';

import 'package:http/http.dart' as http;
import 'Question.dart';

class Quiz {

  Quiz();

  Future<List<Question>> getQuestions(String username, String pin) async {

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
            element['figure'] == null ? questions.add(MultipleChoice(element['stem'], element['option'], element['answer'])) : questions.add(MultipleChoice(element['stem'], element['option'], element['answer'], picture: element['figure']));

            if(element['figure'] != null){
              print(element['stem']);
            }
          } else if (element['type'].toString() == '2') {
            element['figure'] == null ? questions.add(FillInBlank(element['stem'], element['answer'][0])) : questions.add(FillInBlank(element['stem'], element['answer'][0], picture: element['figure']));
          }
        });
      }
    }
    return questions;
  }
}