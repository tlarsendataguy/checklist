import 'dart:async';

import 'package:checklist/src/bookio.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/ui/editorpage.dart';
import 'package:checklist/ui/templates.dart';
import 'package:draggablelistview/draggablelistview.dart';
import 'package:checklist/ui/listviewpopupmenubutton.dart';
import 'package:checklist/ui/strings.dart';
import 'package:commandlist/commandlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:checklist/src/book.dart';

class EditBookBranch extends EditorPage {
  EditBookBranch(String path, ThemeChangeCallback onThemeChanged)
      : super(path, onThemeChanged, const EdgeInsets.all(0.0));

  createState() => new _EditBookBranchState();
}

class _EditBookBranchState extends EditorPageState {
  TextEditingController _listNameController;
  InputDecoration _listNameDecoration;
  String _listType;
  Book _book;
  CommandList<Checklist> _lists;
  BookIo _io = new BookIo();

  initState() {
    super.initState();

    var result = ParsePath.validate(widget.path);
    switch (result) {
      case ParseResult.NormalLists:
        _listType = 'normal';
        break;
      case ParseResult.EmergencyLists:
        _listType = 'emergency';
        break;
      default:
        break;
    }

    initPageState((result) {
      _listNameDecoration = _defaultListNameDecoration();
      _listNameController = new TextEditingController();
      _book = result.book;

      switch (result.result) {
        case ParseResult.NormalLists:
          _lists = _book.normalLists;
          break;
        case ParseResult.EmergencyLists:
          _lists = _book.emergencyLists;
          break;
        default:
          break;
      }
    });
  }

  Widget build(BuildContext context) {
    return buildPage(
      context: context,
      title: Strings.editLists(_listType),
      bodyBuilder: _getBody,
    );
  }

  Widget _getBody(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Expanded(
          child: new DraggableListView<Checklist>(
            rowHeight: 48.0,
            source: _lists,
            builder: _checklistToWidget,
            onMove: (int oldIndex, int newIndex) async {
              var command = _lists.moveItem(oldIndex, newIndex);
              setState(() {});
              if (!await _io.persistBook(_book)) {
                setState(() => command.undo());
              }
            },
          ),
        ),
        new Padding(
          padding: new EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
          child: new Row(
            children: <Widget>[
              new Expanded(
                child: new TextField(
                  onSubmitted: _createChecklist,
                  controller: _listNameController,
                  decoration: _listNameDecoration,
                ),
              ),
              new IconButton(
                icon: new Icon(Icons.add),
                onPressed: null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _defaultListNameDecoration() {
    return new InputDecoration(hintText: Strings.nameHint);
  }

  void _createChecklist(String listName) {
    var list = new Checklist(name: listName);
    var command = _lists.insert(list);
    _io.persistBook(_book).then((bool result) {
      setState(() {
        if (result) {
          _listNameDecoration = new InputDecoration(
            hintText: Strings.nameHint,
          );
          _listNameController.text = "";
        } else {
          command.undo();
          _listNameDecoration = new InputDecoration(
            hintText: Strings.nameHint,
            errorText: Strings.createListFailed,
          );
        }
      });
    });
  }

  Widget _checklistToWidget(Checklist list) {
    var editPath = widget.path + "/" + list.id;

    return new ListViewPopupMenuButton(
      editAction: () => Navigator.of(context).pushNamed(editPath),
      deleteAction: () async {
        var command = _lists.remove(list);
        var success = await _io.persistBook(_book);
        if (!success)
          command.undo();
        else
          setState(() {});
      },
      child: new Container(
        height: 48.0,
        child: new Padding(
          padding: new EdgeInsets.only(left: 16.0),
          child: new Align(
            alignment: new Alignment(-1.0, 0.0),
            child: new Text(
              list.name,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
