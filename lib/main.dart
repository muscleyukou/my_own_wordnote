import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myownwordnote/screens/home_screen.dart';
import 'package:myownwordnote/db/database.dart';

MyDatabase database;
void main() {
  database=MyDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '私の単語帳',
      theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Heira',
      ),
      home: HomeScreen(),
    );
  }
}
