import 'dart:async';

import 'package:checklist/src/bookio.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/ui/editorpage.dart';
import 'package:checklist/ui/strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:checklist/src/book.dart';
import 'package:checklist/ui/templates.dart';
import 'package:checklist/ui/chooselist.dart';

class EditList extends MyAppPage {
  EditList(String path, ThemeChangeCallback onThemeChanged)
      : super(path, onThemeChanged, pagePadding);

  createState() => new _EditListState();
}

class _EditListState extends MyAppPageState {
  TextEditingController _nameController;
  InputDecoration _nameDecoration;
  Book _book;
  Checklist _list;
  var _dropDown = new List<DropdownMenuItem<Checklist>>();
  var _io = new BookIo();

  initState() {
    super.initState();
    _nameDecoration = _defaultNameDecoration();
    initPageState((result) {
      _list = result.list;
      _book = result.book;
      _nameController = new TextEditingController(text: _list.name);
      _generateDropDown();
    });
  }

  Widget build(BuildContext context) {
    return buildPage(
      context: context,
      title: Strings.editList,
      bodyBuilder: _getBody,
    );
  }

  Widget _getBody(BuildContext context) {
    return new ListView(
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
        new RaisedButton(
          onPressed: _setNextPrimary,
          child: new Text(
            _list.nextPrimary == null ?
            Strings.noSelection :
            _list.nextPrimary.name,
          ),
        ),
        editorElementPadding(
          child: themeRaisedButton(
            child: new Text(Strings.editNextAlternatives),
            onPressed: null,
          ),
        ),
      ],
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

  Future _setNextPrimary() async {
    var selection = await chooseList(context,_book);
    if (selection != null){
      var list = selection.list;
      var command = _list.setNextPrimary(list);
      setState((){});
      var success = await _io.persistBook(_book);
      if (!success) setState(()=>command.undo());
    }
  }
}
