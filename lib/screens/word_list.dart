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
        actions: <Widget>[
          IconButton(icon: Icon(Icons.sort),
              onPressed: () => _sortWords(),
              tooltip: "記済の単語が下になるようにソート"),
        ],
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
            builder: (context) =>
                EditScreen(
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
        trailing:
        _wordlist[position].isMemorized ? Icon(Icons.check_circle) : null,
        onTap: () => _editWord(_wordlist[position]),
        onLongPress: () => _deleteword(_wordlist[position]),
      ),
    );
  }

  _deleteword(Word selectedWord) async {
    showDialog(context: context,
        barrierDismissible: false,
        builder: (_)=>
        AlertDialog(
          title: Text(selectedWord.strQuestion),
          content: Text('削除してもいいですか？'),
          actions: <Widget>[
            FlatButton(
              child: Text('はい'),
              onPressed: ()async{
                await database.deleteWord(selectedWord);
                Toast.show("削除が完了しました", context);
                _getAllwords();
                Navigator.pop(context);
              },),
            FlatButton(onPressed:(){Navigator.pop(context);},
                child: Text('いいえ'))
          ]
          ,
        )
    );


  }

  _editWord(Word selectedWord) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditScreen(
                  status: EditStatus.EDIT,
                  word: selectedWord,
                )));
  }

  _sortWords() async {
    _wordlist = await database.allWordsSorted;
    setState(() {});
  }
}
