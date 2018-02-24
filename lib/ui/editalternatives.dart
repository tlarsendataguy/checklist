import 'package:checklist/src/checklist.dart';
import 'package:checklist/ui/strings.dart';
import 'package:commandlist/commandlist.dart';
import 'package:draggablelistview/draggablelistview.dart';
import 'package:flutter/material.dart';

import 'package:checklist/ui/editorpage.dart';
import 'package:checklist/ui/templates.dart';
import 'package:checklist/ui/chooselist.dart';

class EditAlternatives extends EditorPage {
  EditAlternatives(String path, ThemeChangeCallback onThemeChanged)
      : super(path, onThemeChanged, defaultPadding);

  createState() => new EditAlternativesState();
}

class EditAlternativesState extends EditorPageState {
  EditAlternativesState();

  CommandList<Checklist> _alternatives;

  initState() {
    super.initState();
    initEditorState((result) {
      _alternatives = result.list.nextAlternatives;
    });
  }

  Widget build(BuildContext context) {
    return buildPage(
      context: context,
      title: Strings.editNextAlternatives,
      bodyBuilder: _buildBody,
    );
  }

  Widget _buildBody(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Expanded(
          child: new DraggableListView<Checklist>(
            rowHeight: 48.0,
            source: _alternatives,
            builder: _buildListItem,
            onMove: buildOnMove(_alternatives),
          ),
        ),
        new Row(
          children: <Widget>[
            new Expanded(
              child: new Padding(
                child: themeRaisedButton(
                  child: new Text(Strings.addAlternative),
                  onPressed: _addAlternative,
                ),
                padding: defaultLRB,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildListItem(Checklist list) {
    return new Row(
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(left: defaultPad, right: defaultPad),
          child: new IconButton(
            icon: new Icon(Icons.delete),
            onPressed: _deleteAlternative(list),
          ),
        ),
        new Text(list.name),
      ],
    );
  }

  void _addAlternative() async {
    var result = await chooseList(context, book, haveNoSelection: false);
    if (result != null) {
      var command = _alternatives.insert(result.list);
      setState(() {});
      persistBookOrUndo(command);
    }
  }

  Function _deleteAlternative(Checklist list) {
    return () async {
      bool result = await showDialog<bool>(
        barrierDismissible: false,
        context: context,
        child: new AlertDialog(
          title: new Text(Strings.deleteTitle),
          content: new Text(Strings.deleteContent),
          actions: <Widget>[
            themeFlatButton(
              child: new Text(Strings.cancel),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            themeRaisedButtonReversed(
              child: new Text(Strings.deleteTitle),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );

      if (result) {
        var command = _alternatives.remove(list);
        setState(() {});
        persistBookOrUndo(command);
      }
    };
  }
}
