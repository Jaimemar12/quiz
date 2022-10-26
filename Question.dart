abstract class Question {
  final String _stem;
  dynamic _choices;
  final dynamic _answer;
  dynamic _userChoice;
  late int _range;
  bool _isAnswered = false;
  String ?picture;


  Question(this._stem, this._answer, {this.picture});

  get stem => _stem;
  get choices => _choices;
  get answer => _answer;
  get range => _range;
  bool get isAnswered => _isAnswered;

  void userChoice(dynamic value) {
    _userChoice = value;
  }

  void hasBeenAnswered(){
    _isAnswered = true;
  }

  int getScore(){
    if(_userChoice == null){
      return 0;
    }

    if(_answer.runtimeType == List){
      return _userChoice.toString() == _answer[0].toString() ? 1 : 0;
    } else {
      return _userChoice.toString() == _answer.toString() ? 1 : 0;
    }
  }

  dynamic getUserChoice(){
    return _userChoice;
  }
}

class MultipleChoice extends Question{
  MultipleChoice(super.stem, choices, super.answer, {super.picture}) {
    _choices = choices;
    _range = choices.length;
  }
}

class FillInBlank extends Question {
  FillInBlank(super.stem, super.answer, {super.picture}){
    _choices = "";
  }
}