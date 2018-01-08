import 'dart:async';

import 'package:checklist/src/bookio.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/ui/strings.dart';
import 'package:commandlist/commandlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:checklist/src/book.dart';

class EditBookBranch extends StatefulWidget {
  final String path;

  EditBookBranch(this.path);

  createState() => new _EditBookBranchState();
}

class _EditBookBranchState extends State<EditBookBranch> {
  TextEditingController _listNameController;
  InputDecoration _listNameDecoration;
  bool _isLoading = true;
  String _listType;
  Book _book;
  CommandList<Checklist> _lists;
  var _widgetLists = new List<Widget>();

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
        _populateListView();
        _isLoading = false;
      });
    });
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Strings.editLists(_listType)),
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
            child: new ListView(
              children: _widgetLists,
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
    var list = new Checklist(listName);
    var io = new BookIo();
    var command = _lists.insert(list);
    io.persistBook(_book).then((bool result) {
      setState(() {
        if (result) {
          _populateListView();
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

  void _populateListView() {
    _widgetLists = new List<Widget>();
    for (var list in _lists) {
      _widgetLists.add(_checklistToWidget(list));
    }
  }

  Widget _checklistToWidget(Checklist list) {
    return new Text(list.name);
  }
}
