import 'package:checklist/src/checklist.dart';
import 'package:checklist/ui/strings.dart';
import 'package:commandlist/commandlist.dart';
import 'package:draggablelistview/draggablelistview.dart';
import 'package:flutter/material.dart';

import 'package:checklist/ui/editorpage.dart';
import 'package:checklist/ui/templates.dart';
import 'package:checklist/ui/chooselist.dart';
import 'package:checklist/ui/listviewpageframe.dart';

class EditAlternatives extends EditorPage {
  EditAlternatives(String path)
      : super(
          title: Strings.editNextAlternatives,
          path: path,
        );

  createState() => new _EditAlternativesState();
}

class _EditAlternativesState extends EditorPageState {
  CommandList<Checklist> _alternatives;

  void afterParseInit() {
    _alternatives = parseResult.list.nextAlternatives;
  }

  Widget build(BuildContext context) {
    return buildEditorPage(_buildBody);
  }

  Widget _buildBody() {
    return ListViewPageFrame(
      listContent: new DraggableListView<Checklist>(
        rowHeight: 48.0,
        source: _alternatives,
        builder: _buildListItem,
        onMove: buildOnMove(_alternatives),
      ),
      bottomContent: themeRaisedButton(
        child: new Text(Strings.addAlternative),
        onPressed: _addAlternative,
      ),
    );
  }

  Widget _buildListItem(Checklist list) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: _deleteAlternative(list),
        ),
        overflowText(list.name,TextStyle(fontSize: 16.0)),
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
        builder: (context) => AlertDialog(
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
