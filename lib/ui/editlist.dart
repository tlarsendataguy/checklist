import 'package:checklist/src/bookio.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/ui/strings.dart';
import 'package:commandlist/commandlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:checklist/src/book.dart';

class EditList extends StatefulWidget {
  final String path;

  EditList(this.path);

  createState() => new _EditListState();
}

class _EditListState extends State<EditList> {
  TextEditingController _nameController;
  InputDecoration _nameDecoration;
  bool _isLoading = true;
  Book _book;
  Checklist _list;
  var _buttonInsets = const EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 0.0);
  var _dropDown = new List<DropdownMenuItem<Checklist>>();
  var _io = new BookIo();

  initState() {
    super.initState();
    _nameDecoration = _defaultNameDecoration();

    ParsePath
        .parseList(widget.path)
        .then((ChecklistWithParent parsedList) {
      setState(() {
        _list = parsedList.list;
        _book = parsedList.parent;
        _nameController = new TextEditingController(text: _list.name);
        _generateDropDown();
        _isLoading = false;
      });
    });
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Strings.editList),
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
      return new Padding(
        padding: new EdgeInsets.all(12.0),
        child: new ListView(
          children: <Widget>[
            new TextField(
              controller: _nameController,
              decoration: _nameDecoration,
            ),
            new Padding(
              padding: new EdgeInsets.all(32.0),
              child: new RaisedButton(
                child: new Text(Strings.editItems),
                onPressed: null,
              ),
            ),
            new Padding(
              padding: _buttonInsets,
              child: new Column(
                children: <Widget>[
                  new Text(Strings.editNextPrimary),
                  new DropdownButton(
                    value: _list.nextPrimary,
                    items: _dropDown,
                    onChanged: (Checklist selection) async {
                      var command = _list.setNextPrimary(selection);
                      var success = await _io.persistBook(_book);
                      if (!success) setState(() => command.undo());
                    },
                  ),
                ],
              ),
            ),
            new Padding(
              padding: _buttonInsets,
              child: new RaisedButton(
                child: new Text(Strings.editNextAlternatives),
                onPressed: null,
              ),
            ),
          ],
        ),
      );
  }

  InputDecoration _defaultNameDecoration() {
    return new InputDecoration(hintText: Strings.nameHint);
  }

  void _generateDropDown() {
    _dropDown.clear();
    _dropDown.add(
      new DropdownMenuItem<Checklist>(
        child: new Text(Strings.noSelection),
        value: null,
      ),
    );
    for (var list in _book.normalLists) {
      _dropDown.add(
        new DropdownMenuItem<Checklist>(
          child: new Text(list.name),
          value: list,
        ),
      );
    }
  }
}
