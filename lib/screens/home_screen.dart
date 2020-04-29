import 'package:flutter/material.dart';
import 'package:myownwordnote/parts/button_with_icon.dart';
import 'package:myownwordnote/screens/test_screen.dart';
import 'package:myownwordnote/screens/word_list.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isIncludedMemorizedWords = false; //radloボタンを含んでいるか
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: <Widget>[
          Expanded(child: Image.asset('assets/image/image_title.png')),
          _titleText(),
          Divider(
            height: 30.0,
            color: Colors.white,
            indent: 8.0,
            endIndent: 8.0,
          ),
          ButtonWithIcon(
            onPressed: () => _startTestScreen(context),
            icon: Icon(Icons.play_arrow),
            label: 'かくにんテストをする', //todo
            color: Colors.green,
          ),
          SizedBox(
            height: 10.0,
          ),
          _radiobuttons(),
          SizedBox(
            height: 30.0,
          ),
          ButtonWithIcon(
            onPressed: () => _startWordListScreen(context),
            label: '単語一覧をみる',
            color: Colors.blue,
            icon: Icon(Icons.list),
          ),
          SizedBox(
            height: 40.0,
          ),
          Text(
            "powered by yukou",
            style: TextStyle(fontFamily: 'Niku'),
          ),
          SizedBox(
            height: 16.0,
          ),
        ],
      )),
    );
  }

  _titleText() {
    return Padding(
      padding: const EdgeInsets.only(left: 50.0),
      child: Column(
        children: <Widget>[
          Text(
            '私だけの単語帳',
            style: TextStyle(
              fontSize: 40.0,
            ),
          ),
          Text(
            'My Own Frashcard',
            style: TextStyle(fontSize: 24.0, fontFamily: 'Niku'),
          ),
        ],
      ),
    );
  }

  Widget _radiobuttons() {
    return Column(
      children: <Widget>[
        RadioListTile(
          value: false,
          groupValue: isIncludedMemorizedWords,
          title: Text(
            '暗記済みの単語を除外する',
            style: TextStyle(fontSize: 16.0),
          ),
          onChanged: (value) => _onRadioSelected(value),
        ),
        RadioListTile(
          value: true,
          groupValue: isIncludedMemorizedWords,
          title: Text(
            '暗記済みの単語を含む',
            style: TextStyle(fontSize: 16.0),
          ),
          onChanged: (value) => _onRadioSelected(value)
        ),
      ],
    );
  }

  _onRadioSelected(value) {
    setState(() {
      isIncludedMemorizedWords = value;
      print("$valueが選ばれた〜");
    });
  }

  _startWordListScreen(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => WordListScreen()));
  }

  _startTestScreen(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TestScreen(
                  isIncludedMemorizedWords: isIncludedMemorizedWords,
                )));
  }
}
