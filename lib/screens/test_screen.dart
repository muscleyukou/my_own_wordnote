import 'package:flutter/material.dart';
import 'package:myownwordnote/db/database.dart';
import 'package:myownwordnote/main.dart';

enum TestStatus { BEFORE_START, SHOW_QUESTION, SHOW_ANSWER, FINISHED }

class TestScreen extends StatefulWidget {
  final bool isIncludedMemorizedWords;

  TestScreen({this.isIncludedMemorizedWords});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _numberOfQuestion = 0;
  String _txtQuestion = 'テスト';
  String _txtAnswer = "答え";
  bool _isMemorized = false;
  bool _isQuestionCardVisible = false;
  bool _isAnswerCardVisible = false;
  bool _isFabVisible = false;
  bool _checkBoxVisible = false;

  List<Word> _testDataList = List();
  TestStatus _testStatus;

  int _index = 0;
  Word _currentWord;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getTestData();
  }

  void _getTestData() async {
    if (widget.isIncludedMemorizedWords) {
      _testDataList = await database.allWords;
    } else {
      _testDataList = await database.allWordsExcludedMemorized;
    }
    _testDataList.shuffle();
    _testStatus = TestStatus.BEFORE_START;
    _index = 0;

    print(_testDataList.toString());
    setState(() {
      _isQuestionCardVisible = false;
      _isAnswerCardVisible = false;
      _isFabVisible = true;
      _checkBoxVisible = false;
      _numberOfQuestion = _testDataList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _returnHomeScreen(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("かくにんテスト"),
          centerTitle: true,
        ),
        floatingActionButton: _isFabVisible
            ? FloatingActionButton(
                onPressed: () => _goNextStatus(),
                child: Icon(Icons.skip_next),
                tooltip: "次にすすむ",
              )
            : null,
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(
                  height: 10.0,
                ),
                _numberOfQuestionPartsOf(),
                SizedBox(
                  height: 30.0,
                ),
                _numberOfCardPartsOf(),
                SizedBox(
                  height: 20.0,
                ),
                _answerCardPart(),
                SizedBox(
                  height: 10.0,
                ),
                _isMemorizedCheckPart(),
              ],
            ),
            _endMessage(),
          ],
        ),
      ),
    );
  }

//todo 残り問題数表示部分
  Widget _numberOfQuestionPartsOf() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          '残り問題数',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 20.0,
        ),
        Text(
          _numberOfQuestion.toString(),
          style: TextStyle(fontSize: 24.0),
        ),
      ],
    );
  }

//todo 問題カード表示部分
  Widget _numberOfCardPartsOf() {
    if (_isQuestionCardVisible) {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.asset("assets/image/image_flash_question.png"),
          Text(
            _txtQuestion,
            style: TextStyle(
                fontSize: 30.0,
                color: Colors.grey[800],
                fontWeight: FontWeight.bold),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

//todo 答えカード表示
  Widget _answerCardPart() {
    if (_isAnswerCardVisible) {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.asset('assets/image/image_flash_answer.png'),
          Text(
            _txtAnswer,
            style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _isMemorizedCheckPart() {
    if (_checkBoxVisible) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 10.0),
        child: CheckboxListTile(
          value: _isMemorized,
          onChanged: (value) {
            setState(() {
              _isMemorized = value;
            });
          },
          title: Text(
            "暗記をする場合にはチェックを入れてください",
            style: TextStyle(fontSize: 14.0),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  _goNextStatus() async {
    switch (_testStatus) {
      case TestStatus.BEFORE_START:
        _testStatus = TestStatus.SHOW_QUESTION;
        _showQuestion();
        break;
      case TestStatus.SHOW_QUESTION:
        _testStatus = TestStatus.SHOW_ANSWER;
        _showAnswer();
        break;
      case TestStatus.SHOW_ANSWER:
        await _updateMemorized();
        if (_numberOfQuestion <= 0) {
          setState(() {
            _testStatus = TestStatus.FINISHED;
            _isFabVisible = false;
          });
        } else {
          _testStatus = TestStatus.SHOW_QUESTION;
          _showQuestion();
        }
        break;
      case TestStatus.FINISHED:
        break;
    }
  }

  //テスト終了メッセージ
  Widget _endMessage() {
    if (_testStatus == TestStatus.FINISHED) {
      return Center(
          child: Text(
        'テスト終了',
        style: TextStyle(fontSize: 50.0),
      ));
    } else {
      return Container();
    }
  }

  void _showQuestion() {
    _currentWord = _testDataList[_index];
    setState(() {
      _isQuestionCardVisible = true;
      _isAnswerCardVisible = false;
      _isFabVisible = true;
      _checkBoxVisible = false;
      _txtQuestion = _currentWord.strQuestion;
    });
    _numberOfQuestion -= 1;
    _index += 1;
  }

  void _showAnswer() {
    setState(() {
      _isQuestionCardVisible = true;
      _isAnswerCardVisible = true;
      _isFabVisible = true;
      _checkBoxVisible = true;
      _txtAnswer = _currentWord.strAnswer;
      _isMemorized = _currentWord.isMemorized;
    });
  }

  Future<void> _updateMemorized() async {
    var updateWord = Word(
        strQuestion: _currentWord.strQuestion,
        strAnswer: _currentWord.strAnswer,
        isMemorized: _isMemorized);
    await database.updateWord(updateWord);
    print(updateWord.toString());
  }

  Future<bool> _returnHomeScreen() async {
    return await showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('テストの終了'),
              content: Text('テストを終了しても良いですか？'),
              actions: <Widget>[
                FlatButton(
                  child: Text('はい'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text('いいえ'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ))??false;
  }
}
