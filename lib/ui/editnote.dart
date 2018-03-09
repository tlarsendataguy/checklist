import 'package:checklist/src/note.dart';
import 'package:checklist/ui/editorpage.dart';
import 'package:checklist/ui/strings.dart';
import 'package:checklist/ui/templates.dart';
import 'package:flutter/material.dart';

class EditNote extends EditorPage {
  EditNote(String path,ThemeChangeCallback onThemeChanged) :
      super(path:path,onThemeChanged: onThemeChanged, title: Strings.editNote);

  createState() => new EditNoteState();
}

class EditNoteState extends EditorPageState {

  Note note;

  afterParseInit(){
    note = parseResult.note;
  }

  Widget build(BuildContext context) {
    return buildEditorPage(()=>Text(note.text));
  }
}