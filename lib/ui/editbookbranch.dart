import 'dart:async';

import 'package:checklist/src/bookio.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/ui/templates.dart';
import 'package:draggablelistview/draggablelistview.dart';
import 'package:checklist/ui/listviewpopupmenubutton.dart';
import 'package:checklist/ui/strings.dart';
import 'package:commandlist/commandlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:checklist/src/book.dart';

class EditBookBranch extends StatefulWidget {
  EditBookBranch(this.path, this.onThemeChanged);

  final String path;
  final ThemeChangeCallback onThemeChanged;

  createState() => new _EditBookBranchState();
}

class _EditBookBranchState extends State<EditBookBranch> {
  TextEditingController _listNameController;
  InputDecoration _listNameDecoration;
  bool _isLoading = true;
  String _listType;
  Book _book;
  CommandList<Checklist> _lists;
  BookIo _io = new BookIo();

  initState() {
    super.initState();
    _listNameDecoration = _defaultListNameDecoration();
    _listNameController = new TextEditingController();

    ParsePath.parseBook(widget.path).then((Book parsedBook) {
      setState(() {
        _book = parsedBook;
        List<String> elements = widget.path.split('/');
        _listType = elements[elements.length - 1];
        if (_listType == 'normal')
          _lists = parsedBook.normalLists;
        else
          _lists = parsedBook.emergencyLists;
        _isLoading = false;
      });
    });
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: themeAppBar(
        title: Strings.editLists(_listType),
        onThemeChanged: widget.onThemeChanged,
      ),
      body: _getBody(context),
    );
  }

  Widget _getBody(BuildContext context) {
    if (_isLoading)
      return new Center(
        child: new CupertinoActivityIndicator(),
      );
    else
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
