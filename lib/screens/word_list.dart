import 'package:flutter/material.dart';
import 'package:myownwordnote/db/database.dart';
import 'package:myownwordnote/main.dart';
import 'package:myownwordnote/screens/edit_screen.dart';
import 'package:toast/toast.dart';

class WordListScreen extends StatefulWidget {
  @override
  _WordListScreenState createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  List<Word> _wordlist = List();

  @override
  void initState() {
    super.initState();
    _getAllwords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('単語一覧'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewWord(),
        child: Icon(Icons.add),
        tooltip: '新しい単語の登録',
      ),
      body: _wordListWidget(), //todo
    );
  }

  _addNewWord() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => EditScreen(
                  status: EditStatus.ADD,
                )));
  }

  void _getAllwords() async {
    _wordlist = await database.allWords;
    setState(() {});
  }

  Widget _wordListWidget() {
    return ListView.builder(
        itemCount: _wordlist.length,
        itemBuilder: (context, int position) => _wordItem(position));
  }

  Widget _wordItem(int position) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      color: Colors.grey,
      child: ListTile(
        title: Text(
          "${_wordlist[position].strQuestion}",
        ),
        subtitle: Text(
          "${_wordlist[position].strAnswer}",
          style: TextStyle(fontFamily: "Mont"),
        ),
        onTap: () => _editWord(_wordlist[position]),
        onLongPress: () => _deleteword(_wordlist[position]),
      ),
    );
  }

  _deleteword(Word selectedWord) async {
    await database.deleteWord(selectedWord);
    Toast.show("削除が完了しました", context);
    _getAllwords();
  }

  _editWord(Word selectedWord) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => EditScreen(
                  status: EditStatus.EDIT,
                  word: selectedWord,
                )));
  }
}
