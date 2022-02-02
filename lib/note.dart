import 'dart:ui';

import 'package:flutter/material.dart';

class Note {
  final int? id;
  final String title;
  final String content;
  final Color color;
  final DateTime editTime;
  final bool pinned;

  const Note({
    this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.editTime,
    required this.pinned,
  });

  Note.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        title = map['title'],
        content = map['content'],
        color = Color(map['color']),
        editTime = DateTime.parse(map['edit_time']),
        pinned = map['pinned'] == 1;

  Note copyWith({
    int? id,
    String? title,
    String? content,
    Color? color,
    DateTime? editTime,
    bool? pinned,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      editTime: editTime ?? this.editTime,
      pinned: pinned ?? this.pinned,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'color': color.value,
      'edit_time': editTime.toIso8601String(),
      'pinned': pinned ? 1 : 0,
    };
  }
}

const Color defaultNoteColor = Color(0xFF1F1F1F);
const List<Color> noteColors = [
  defaultNoteColor,
  Color(0xff005f73),
  Color(0xff0a9396),
  Color(0xff94d2bd),
  Color(0xffe9d8a6),
  Color(0xffee9b00),
  Color(0xffca6702),
  Color(0xffbb3e03),
  Color(0xffae2012),
  Color(0xff9b2226),
];
