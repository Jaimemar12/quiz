import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quiz/APIHandler.dart';

import 'Question.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(title: 'Login'),
    );
  }
}

class MainScreen extends StatefulWidget {
  final String username;
  final String pin;

  const MainScreen(this.username, this.pin, {super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
  String numberOfQuestions = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
              child: Column(
            children: [
              Text(
                'Welcome ${widget.username}!',
                style: const TextStyle(fontSize: 30),
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                'Select the number of questions for your quiz.',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ],
          )),
          const SizedBox(height: 30),
          Container(
              padding: const EdgeInsets.fromLTRB(50.0, 10, 50, 10),
              child: Column(
                children: [
                  Form(
                    key: _keyForm,
                    child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        validator: (String? inValue) {
                          if (int.tryParse(inValue!) == null) {
                            return "Please enter a valid number";
                          }

                          if (int.parse(inValue) < 1 ||
                              int.parse(inValue) > 136) {
                            return "Please select between 1-136";
                          }

                          return null;
                        },
                        onSaved: (String? inValue) {
                          numberOfQuestions = inValue!;
                        },
                        decoration: const InputDecoration(labelText: "Answer")),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    child: const Text('Start Quiz'),
                    onPressed: () {
                      if (_keyForm.currentState!.validate()) {
                        _keyForm.currentState?.save();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QuizScreen(widget.username,
                                  widget.pin, numberOfQuestions)),
                        );
                      }
                    },
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final String username;
  final String pin;
  final String numberOfQuestions;

  const QuizScreen(this.username, this.pin, this.numberOfQuestions,
      {super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<Question>> _questions;
  late List<Question> questions;
  bool hasBeenSet = false;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    _questions = APIHandler.getQuestions(widget.username, widget.pin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Questions"),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Submit',
                child: Text(
                  'Submit',
                ),
              ),
              const PopupMenuItem(
                value: 'Help',
                child: Text(
                  'Help',
                ),
              ),
            ],
            onSelected: (value) {
              if (value == "Submit") {
                runApp(MaterialApp(
                  theme: ThemeData.dark(),
                  debugShowCheckedModeBanner: false,
                  home: ReviewScreen(questions, title: "Review"),
                ));
              } else if (value == "Help") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const HelpScreen(title: "Help Menu")));
              }
            },
            icon: const Icon(Icons.menu),
          )
        ],
      ),
      body: FutureBuilder<List<Question>>(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (hasBeenSet != true) {
              List<Question> temp = snapshot.data!;
              questions = [];

              for (int i = 0; i < int.parse(widget.numberOfQuestions); i++) {
                questions.add(temp[Random().nextInt(temp.length)]);
              }
              hasBeenSet = true;
            }
            return ListView.builder(
                itemCount: questions.length,
                itemBuilder: (_, index) {
                  if (index == 0) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 12,
                            ),
                            Text(
                              "$counter/${widget.numberOfQuestions}",
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 90,
                            ),
                            const Text(
                              "Question",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 90,
                            ),
                            const Text(
                              "Question Type",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        ListTile(
                          title: TextButton(
                            onPressed: questions[index].isAnswered
                                ? null
                                : () async {
                                    bool? refreshed = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => questions[index]
                                                      .runtimeType ==
                                                  MultipleChoice
                                              ? MultipleChoiceQuestionScreen(
                                                  questions[index],
                                                  title:
                                                      'Question #${index + 1}',
                                                )
                                              : FillInBlankQuestionScreen(
                                                  questions[index],
                                                  title:
                                                      'Question #${index + 1}',
                                                )),
                                    );

                                    if (refreshed != null && refreshed) {
                                      setState(() {
                                        counter++;
                                        questions[index].hasBeenAnswered();
                                      });
                                    }
                                  },
                            child:
                                Text('#${index + 1} ${questions[index].stem}'),
                          ),
                          leading: Icon(questions[index].isAnswered
                              ? Icons.check_box
                              : Icons.check_box_outline_blank),
                          trailing:
                              Text(questions[index].runtimeType.toString()),
                        ),
                      ],
                    );
                  } else {
                    return ListTile(
                      title: TextButton(
                        onPressed: questions[index].isAnswered
                            ? null
                            : () async {
                                bool? refreshed = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => questions[index]
                                                  .runtimeType ==
                                              MultipleChoice
                                          ? MultipleChoiceQuestionScreen(
                                              questions[index],
                                              title: 'Question #${index + 1}',
                                            )
                                          : FillInBlankQuestionScreen(
                                              questions[index],
                                              title: 'Question #${index + 1}',
                                            )),
                                );

                                if (refreshed != null && refreshed) {
                                  setState(() {
                                    counter++;
                                    questions[index].hasBeenAnswered();
                                  });
                                }
                              },
                        child: Text('#${index + 1} ${questions[index].stem}'),
                      ),
                      leading: Icon(questions[index].isAnswered
                          ? Icons.check_box
                          : Icons.check_box_outline_blank),
                      trailing: Text(questions[index].runtimeType.toString()),
                    );
                  }
                });
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong :('));
          }
          return const Center(child: CircularProgressIndicator());
        },
        future: _questions,
      ),
    );
  }
}

class LoginData {
  String username = "";
  String pin = "";
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginData _loginData = LoginData();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _showContent(bool isValid) {
    if (isValid) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MainScreen(_loginData.username, _loginData.pin)),
      );
    } else {
      showDialog(
        context: context, barrierDismissible: false, // user must tap button!

        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Incorrect Username/Password'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const [
                  Text('Click OK to Close.'),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.all(50.0),
        child: Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? inValue) {
                    if (inValue!.isEmpty) {
                      return "Please enter username";
                    }

                    return null;
                  },
                  onSaved: (String? inValue) {
                    _loginData.username = inValue!;
                  },
                  decoration: const InputDecoration(labelText: "Username")),
              TextFormField(
                  obscureText: true,
                  validator: (String? inValue) {
                    if (inValue == null || inValue.length != 4) {
                      return "Pin must be 4 in length";
                    }
                    return null;
                  },
                  onSaved: (String? inValue) {
                    _loginData.pin = inValue!;
                  },
                  decoration: const InputDecoration(
                      hintText: "xxxx", labelText: "Pin")),
              ElevatedButton(
                  child: const Text("Enter"),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState?.save();
                      bool validation = await validateLogin();

                      if (validation) {
                        _showContent(true);
                      } else {
                        _showContent(false);
                      }
                    }
                  })
            ])),
      ),
    );
  }

  Future<bool> validateLogin() async {
    var url = Uri.parse(
        'https://www.cs.utep.edu/cheon/cs4381/homework/quiz/login.php?user=${_loginData.username}&pin=${_loginData.pin}');
    var response = await http.get(url);
    var decoded = json.decode(response.body);

    return decoded['response'].toString() == 'true';
  }
}

class MultipleChoiceQuestionScreen extends StatefulWidget {
  final Question question;
  final String title;

  const MultipleChoiceQuestionScreen(this.question,
      {required this.title, super.key});

  @override
  State<MultipleChoiceQuestionScreen> createState() =>
      _MultipleChoiceQuestionScreenState();
}

class _MultipleChoiceQuestionScreenState
    extends State<MultipleChoiceQuestionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView.builder(
            itemCount: widget.question.choices.length,
            itemBuilder: (_, index) {
              if (index == 0) {
                return Column(
                  children: [
                    Container(
                        padding: const EdgeInsets.fromLTRB(50.0, 50, 50, 90),
                        child: Text(
                          widget.question.stem,
                          style: const TextStyle(fontSize: 25),
                          textAlign: TextAlign.center,
                        )),
                    ListTile(
                      title: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              widget.question.userChoice(index + 1);
                            });

                            Navigator.of(context).pop(true);
                          },
                          child: Text('${widget.question.choices[index]}')),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  ListTile(
                    title: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            widget.question.userChoice(index + 1);
                          });
                          Navigator.of(context).pop(true);
                        },
                        child: Text('${widget.question.choices[index]}')),
                  ),
                ],
              );
            }));
  }
}

class FillInBlankQuestionScreen extends StatefulWidget {
  final Question question;
  final String title;

  const FillInBlankQuestionScreen(this.question,
      {required this.title, super.key});

  @override
  State<FillInBlankQuestionScreen> createState() =>
      _FillInBlankQuestionScreenState();
}

class _FillInBlankQuestionScreenState extends State<FillInBlankQuestionScreen> {
  final GlobalKey<FormState> _keyForm = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              padding: const EdgeInsets.fromLTRB(50.0, 0, 50, 0),
              child: Text(
                widget.question.stem,
                style: const TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              )),
          Container(
            padding: const EdgeInsets.fromLTRB(100, 100, 100, 0),
            child: Form(
                key: _keyForm,
                child: Column(children: [
                  TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      validator: (String? inValue) {
                        if (inValue!.isEmpty) {
                          return "Please enter an answer";
                        }
                        return null;
                      },
                      onSaved: (String? inValue) {
                        setState(() {
                          widget.question.userChoice(inValue.toString());
                        });
                      },
                      decoration: const InputDecoration(labelText: "Answer")),
                  ElevatedButton(
                      child: const Text("Enter"),
                      onPressed: () async {
                        if (_keyForm.currentState!.validate()) {
                          _keyForm.currentState?.save();
                          Navigator.of(context).pop(true);
                        }
                      })
                ])),
          )
        ],
      )),
    );
  }
}

class ReviewScreen extends StatefulWidget {
  final String title;
  final List<Question> questions;

  const ReviewScreen(this.questions, {required this.title, super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int counter = 0;
  String getScore() {
    for (int i = 0; i < widget.questions.length; i++) {
      counter += widget.questions[i].getScore();
    }
    return "$counter";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text(getScore()),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ),
    );
  }
}

class HelpScreen extends StatefulWidget {
  final String title;

  const HelpScreen({required this.title, super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Container(
                  padding: const EdgeInsets.fromLTRB(50.0, 0, 50, 0),
                  child: const Text(
                    'Select one of the questions to answer. Once answered, the box on its left'
                    ' will be checked off and the question will be disabled '
                    'to open again as it has already been answered. '
                    'Once done press submit to see review score.',
                    style: TextStyle(fontSize: 25),
                  )),
            ])));
  }
}
