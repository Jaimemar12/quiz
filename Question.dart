abstract class Question {
  final String _stem;
  dynamic _choices;
  final dynamic _answer;
  dynamic _userChoice;
  late int _range;
  bool _isAnswered = false;


  Question(this._stem, this._answer);

  get stem => _stem;
  get choices => _choices;
  get answer => _answer;
  get score => _userChoice == _answer ? 1 : 0;
  get range => _range;
  bool get isAnswered => _isAnswered;

  void userChoice(dynamic value) {
    _userChoice = value;
  }

  void hasBeenAnswered(){
    _isAnswered = true;
  }
}

class MultipleChoice extends Question{
  MultipleChoice(super.stem, choices, super.answer) {
    _choices = choices;
    _range = choices.length;
  }

  MultipleChoice.trueQuestion(String stem): this(stem, ['true', 'false'], 1);
  MultipleChoice.falseQuestion(String stem): this(stem, ['true', 'false'], 2);
}

class FillInBlank extends Question {
  FillInBlank(super.stem, super.answer){
    _choices = "";
  }
}