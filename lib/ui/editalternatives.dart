import 'package:checklist/src/checklist.dart';
import 'package:checklist/ui/strings.dart';
import 'package:commandlist/commandlist.dart';
import 'package:draggablelistview/draggablelistview.dart';
import 'package:flutter/material.dart';

import 'package:checklist/ui/editorpage.dart';
import 'package:checklist/ui/templates.dart';

class EditAlternatives extends EditorPage {
  EditAlternatives(String path,ThemeChangeCallback onThemeChanged) :
      super(path,onThemeChanged, defaultPadding);

  createState() => new EditAlternativesState();
}

class EditAlternativesState extends EditorPageState {
  EditAlternativesState();

  CommandList<Checklist> _alternatives;

  initState(){
    super.initState();
    initEditorState((result){
      _alternatives = result.list.nextAlternatives;
    });
  }

  Widget build(BuildContext context){
    return buildPage(
      context: context,
      title: Strings.editNextAlternatives,
      bodyBuilder: _buildBody,
    );
  }

  Widget _buildBody(BuildContext context){
    return new DraggableListView<Checklist>(
      rowHeight: 48.0,
      source: _alternatives,
      builder: _buildListItem,
      onMove: buildOnMove(_alternatives),
    );
  }

  Widget _buildListItem(Checklist list){
    return new Text(list.name);
  }
}
