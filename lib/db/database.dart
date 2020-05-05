import 'dart:io';
import 'package:moor/moor.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Words extends Table {
  TextColumn get strQuestion => text()();

  TextColumn get strAnswer => text()();

  BoolColumn get isMemorized => boolean().withDefault(Constant(false))();

  @override
  Set<Column> get primaryKey => {strQuestion};
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'words.db'));
    return VmDatabase(file);
  });
}

@UseMoor(tables: [Words])
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super(_openConnection());

  @override
  // TODO: implement schemaVersion
  int get schemaVersion => 2;

//統合処理
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (Migrator m) {
        return m.createAll();
      }, onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1) {
          await m.addColumn(words, words.isMemorized);
        }
      });

  //create
  Future addWord(Word word) => into(words).insert(word);

  //read
  Future<List<Word>> get allWords => select(words).get();

  //renew暗記済
  Future<List<Word>> get allWordsExcludedMemorized =>
      (select(words)
        ..where((table) => table.isMemorized.equals(false))).get();

  //暗記済の単語が下になるようにソート
  Future<List<Word>> get allWordsSorted =>
      (select(words)
        ..orderBy([(table)=>OrderingTerm(expression:table.isMemorized)])).get();

  // update
  Future updateWord(Word word) => update(words).replace(word);

  //delete
  Future deleteWord(Word word) =>
      (delete(words)
        ..where((t) => t.strQuestion.equals(word.strQuestion)))
          .go();
}
