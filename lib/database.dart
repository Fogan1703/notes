import 'package:flutter/cupertino.dart';
import 'package:notes/note.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseModel extends ChangeNotifier {
  static const String table = 'notes';

  Future<List<Note>> get notes {
    return _database.query(table).then((maps) {
      return maps.map((map) => Note.fromMap(map)).toList();
    });
  }

  final Database _database;

  DatabaseModel(this._database);

  void saveNote(Note note) {
    notifyListeners();
    if (note.id != null) {
      _database.update(
        table,
        note.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
    } else {
      _database.insert(table, note.toMap());
    }
  }

  void deleteNote(Note note) {
    notifyListeners();
    _database.delete(
      table,
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> insertNote(Note note) {
    notifyListeners();
    return _database.insert(table, note.toMap());
  }

  Future<List<Note>>? search(String query) {
    if (query.isEmpty) {
      return null;
    } else {
      return notes.then((notes) {
        query = query.toLowerCase();
        final List<Note> result = [];
        for (var note in notes) {
          if (note.title.toLowerCase().contains(query) ||
              note.content.toLowerCase().contains(query)) {
            result.add(note);
          }
        }
        return result;
      });
    }
  }
}
