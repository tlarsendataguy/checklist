import 'package:checklist/src/note.dart';
import 'package:checklist/ui/editorpage.dart';
import 'package:checklist/ui/strings.dart';
import 'package:checklist/ui/templates.dart';
import 'package:commandlist/commandlist.dart';
import 'package:draggablelistview/draggablelistview.dart';
import 'package:flutter/material.dart';

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

  void afterParseInit() {
    _notes = parseResult.item.notes;
  }

  Widget _buildBody() {
    return Padding(
      padding: EdgeInsets.only(top: listTopPad),
      child: DraggableListView<Note>(
        source: _notes,
        rowHeight: 72.0,
        onMove: buildOnMove(_notes),
        builder: _noteBuilder,
      ),
    );
  }

  Widget _noteBuilder(Note note) {
    return Padding(
      padding: defaultPadding,
      child: Column(
        children: <Widget>[
          Text(note.text),
          Text(Strings.priorityToString(note.priority)),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return buildEditorPage(_buildBody);
  }
}
