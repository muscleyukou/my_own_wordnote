import 'package:flutter/material.dart';
import 'package:moor_ffi/database.dart';
import 'package:myownwordnote/db/database.dart';
import 'package:myownwordnote/main.dart';
import 'package:myownwordnote/screens/word_list.dart';
import 'package:toast/toast.dart';

enum EditStatus { ADD, EDIT }

class EditScreen extends StatefulWidget {
  final EditStatus status;
  final Word word;

  EditScreen({@required this.status, this.word});

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();

  String _titleText = '';

  bool _isQuestionEnabled;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.status == EditStatus.ADD) {
      _isQuestionEnabled = true;
      _titleText = '新しい単語の登録';
      questionController.text = "";
    } else {
      _isQuestionEnabled = false;
      _titleText = '登録した単語の修正';
      questionController.text = widget.word.strQuestion;
      answerController.text = widget.word.strAnswer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _backToWordListScreen(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titleText),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.done),
              tooltip: "登録",
              onPressed: () => _onRegistered(),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                height: 30.0,
              ),
              Center(
                child: Text(
                  "問題と答えを入力して「登録ボタン」を押してください",
                  style: TextStyle(fontSize: 14.0),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 30.0,
              ),
              _questionInputPart(),
              SizedBox(
                width: double.infinity,
                height: 30.0,
              ),
              _answerInputPart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _questionInputPart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: <Widget>[
          Text(
            '問題',
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(
            height: 10.0,
          ),
          TextField(
            enabled: _isQuestionEnabled,
            controller: questionController,
            keyboardType: TextInputType.text,
            style: TextStyle(fontSize: 30.0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  _answerInputPart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: <Widget>[
          Text(
            '答え',
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(
            height: 10.0,
          ),
          TextField(
            controller: answerController,
            keyboardType: TextInputType.text,
            style: TextStyle(fontSize: 30.0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<bool> _backToWordListScreen() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => WordListScreen()));
    return Future.value(false);
  }

  _onRegistered() {
    if (widget.status == EditStatus.ADD) {
      _insertWord();
    } else {
      _updateWord();
    }
  }

  _insertWord() async {
    if (questionController.text == "" || answerController.text == "") {
      Toast.show("問題を入力しないと登録出来ません。", context, duration: Toast.LENGTH_LONG);
      return;
    }
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('登録'),
              content: Text('登録してもいいですか？'),
              actions: <Widget>[
                FlatButton(
                  child: Text('はい'),
                  onPressed: () async {
                    var word = Word(
                      strAnswer: answerController.text,
                      strQuestion: questionController.text,
                    );
                    try {
                      await database.addWord(word);
                      print('OK');
                      questionController.clear();
                      answerController.clear();
                      Toast.show("登録完了しました", context,
                          duration: Toast.LENGTH_LONG);
                    } on SqliteException catch (e) {
                      print(e.toString());
                      Toast.show('この問題はすでに登録されておりますので登録出来ません', context,
                          duration: Toast.LENGTH_LONG);
                    } finally {
                      Navigator.pop(context);
                    }
                  },
                ),
                FlatButton(
                  child: Text('いいえ'),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ));
  }

  void _updateWord() async {
    if (questionController.text == "" || answerController.text == "") {
      Toast.show("問題を入力しないと登録出来ません。", context, duration: Toast.LENGTH_LONG);
      return;
    }
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('${questionController.text}の変更'),
              content: Text('変更してもいいですか？'),
              actions: <Widget>[
                FlatButton(
                  child: Text('はい'),
                  onPressed: () async {
                    var word = Word(
                        strAnswer: answerController.text,
                        strQuestion: questionController.text,
                        isMemorized: false);

                    try {
                      await database.updateWord(word);
                      _backToWordListScreen();
                      Toast.show("登録完了しました", context,
                          duration: Toast.LENGTH_LONG);
                      Navigator.pop(context);
                    } on SqliteException catch (e) {
                      Toast.show('この問題はすでに登録されておりますので登録出来ません', context,
                          duration: Toast.LENGTH_LONG);
                      Navigator.pop(context);
                    }
                  },
                ),
                FlatButton(
                  child: Text('いいえ'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ));
  }
}
