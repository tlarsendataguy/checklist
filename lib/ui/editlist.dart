import 'package:checklist/src/bookio.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/ui/strings.dart';
import 'package:commandlist/commandlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:checklist/src/book.dart';
import 'package:checklist/ui/templates.dart';

class EditList extends StatefulWidget {
  EditList(this.path, this.onThemeChanged);

  final String path;
  final ThemeChangeCallback onThemeChanged;

  createState() => new _EditListState();
}

class _EditListState extends State<EditList> {
  TextEditingController _nameController;
  InputDecoration _nameDecoration;
  bool _isLoading = true;
  Book _book;
  Checklist _list;
  var _dropDown = new List<DropdownMenuItem<Checklist>>();
  var _io = new BookIo();

  initState() {
    super.initState();
    _nameDecoration = _defaultNameDecoration();

    ParsePath.parseList(widget.path).then((ChecklistWithParent parsedList) {
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
      appBar: themeAppBar(
        title: Strings.editList,
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
      return new Padding(
        padding: pagePadding,
        child: new ListView(
          children: <Widget>[
            editorElementPadding(
              child: new TextField(
                controller: _nameController,
                decoration: _nameDecoration,
              ),
            ),
            editorElementPadding(
              child: themeRaisedButton(
                child: overflowText(Strings.editItems),
                onPressed: null,
              ),
            ),
            new Padding(
              padding: const EdgeInsets.only(top: defaultPad * 3),
              child: new Text(Strings.editNextPrimary),
            ),
            new DropdownButton(
              value: _list.nextPrimary,
              items: _dropDown,
              onChanged: (Checklist selection) async {
                var command = _list.setNextPrimary(selection);
                var success = await _io.persistBook(_book);
                if (!success) setState(() => command.undo());
              },
            ),
            editorElementPadding(
              child: themeRaisedButton(
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
        child: overflowText(Strings.noSelection),
        value: null,
      ),
    );
    for (var list in _book.normalLists) {
      _dropDown.add(
        new DropdownMenuItem<Checklist>(
          child: overflowText(list.name),
          value: list,
        ),
      );
    }
  }
}
