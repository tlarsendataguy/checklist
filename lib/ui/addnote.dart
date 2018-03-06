import 'dart:async';
import 'dart:collection';

import 'package:checklist/src/note.dart';
import 'package:checklist/ui/strings.dart';
import 'package:checklist/ui/templates.dart';
import 'package:flutter/material.dart';

Future<Note> addNote(
    BuildContext context, HashSet<Note> existingNotes) async {
  return await showDialog<Note>(
    context: context,
    child: Dialog(
      child: Column(
        children: <Widget>[
          Text(Strings.existingNotes),
          Expanded(
            child: ListView.builder(
              itemCount: existingNotes.length,
              itemBuilder: _getBuilder(existingNotes),
            ),
          ),
          Text(Strings.createNote),
          TextField(),
          TextField(),
        ],
      ),
    ),
  );
}

Widget Function(BuildContext, int) _getBuilder(HashSet<Note> existingNotes) {
  return (BuildContext context, int index) {
    var note = existingNotes.elementAt(index);
    return themeRaisedButton(
      onPressed: () => note,
      child: Column(
        children: <Widget>[
          overflowText(note.text),
          Text(Strings.priorityToString(note.priority)),
        ],
      ),
    );
  };
}
