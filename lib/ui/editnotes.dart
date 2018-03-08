import 'dart:async';
import 'dart:collection';

import 'package:checklist/src/item.dart';
import 'package:checklist/src/note.dart';
import 'package:checklist/ui/addnote.dart';
import 'package:checklist/ui/editorpage.dart';
import 'package:checklist/ui/strings.dart';
import 'package:checklist/ui/templates.dart';
import 'package:commandlist/commandlist.dart';
import 'package:draggablelistview/draggablelistview.dart';
import 'package:flutter/material.dart';
import 'package:checklist/ui/listviewpageframe.dart';

class EditNotes extends EditorPage {
  EditNotes(String path, ThemeChangeCallback onThemeChanged)
      : super(
          title: Strings.editNotes,
          path: path,
          onThemeChanged: onThemeChanged,
        );

  createState() => new EditNotesState();
}

class EditNotesState extends EditorPageState {
  CommandList<Note> _notes;
  var _existingNotes = new HashSet<Note>();

  void afterParseInit() {
    _notes = parseResult.item.notes;
    for (var item in parseResult.list) {
      _fillExistingNotes(item);
    }
  }

  void _fillExistingNotes(Item item) {
    for (var note in item.notes) {
      _existingNotes.add(note);
    }

    for (var list in [item.trueBranch, item.falseBranch]) {
      for (var item in list) {
        _fillExistingNotes(item);
      }
    }
  }

  Widget _buildBody() {
    return ListViewPageFrame(
      listContent: DraggableListView<Note>(
        source: _notes,
        rowHeight: 72.0,
        onMove: buildOnMove(_notes),
        builder: _noteBuilder,
      ),
      bottomContent: themeRaisedButton(
        onPressed: _addNote,
        child: new Text(Strings.addNote),
      ),
    );
  }

  Widget _noteBuilder(Note note) {
    return Padding(
      padding: defaultT,
      child: Column(
        children: <Widget>[
          Text(note.text),
          Text(Strings.priorityToString(note.priority)),
        ],
      ),
    );
  }

  Future _addNote() async {
    var selection = await addNote(context, _existingNotes);
    if (selection == null) return;

    var command = _notes.insert(selection);
    _existingNotes.add(selection);
    setState((){});
    persistBookOrUndo(command);
  }

  Widget build(BuildContext context) {
    return buildEditorPage(_buildBody);
  }
}
