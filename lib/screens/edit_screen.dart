import 'package:flutter/material.dart';
import 'package:moor_ffi/database.dart';
import 'package:myownwordnote/db/database.dart';
import 'package:myownwordnote/main.dart';
import 'package:myownwordnote/screens/word_list.dart';
import 'package:toast/toast.dart';

class EditScreen extends StatefulWidget {
  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  var questionController = TextEditingController();
  var answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _backToWordListScreen(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('新しい単語の登録'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.done),
              tooltip: "登録",
              onPressed: () => _insertWord(),
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

  _insertWord() async {
    if (questionController.text == "" || answerController.text == "") {
      Toast.show("問題を入力しないと登録出来ません。", context, duration: Toast.LENGTH_LONG);
      return;
    }
    var word = Word(
        strAnswer: answerController.text, strQuestion: questionController.text);
    try{
      await database.addWord(word);
      print('OK');
      questionController.clear();
      answerController.clear();
      Toast.show("登録完了しました", context, duration: Toast.LENGTH_LONG);
    }on SqliteException catch(e){
      Toast.show('この問題はすでに登録されておりますので登録出来ません', context,duration: Toast.LENGTH_LONG);
    }

  }
}
