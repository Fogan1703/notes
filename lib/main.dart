import 'package:flutter/material.dart';
import 'package:notes/app.dart';
import 'package:notes/database.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await openDatabase(
    join(
      await getDatabasesPath(),
      'notes_database.db',
    ),
    version: 1,
  );
  database.execute(
      'CREATE TABLE IF NOT EXISTS ${DatabaseModel.table}(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT, content TEXT, color INTEGER, edit_time TEXT, pinned INTEGER)');

  runApp(
    ChangeNotifierProvider(
      create: (context) => DatabaseModel(database),
      child: const App(),
    ),
  );
}
