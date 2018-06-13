import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:checklist/src/checklist.dart';
import 'package:checklist/ui/editorpage.dart';
import 'package:checklist/ui/strings.dart';
import 'package:checklist/ui/templates.dart';
import 'package:checklist/ui/chooselist.dart';

class EditList extends EditorPage {
  EditList(String path)
      : super(
          title: Strings.editList,
          path: path,
        );

  createState() => new _EditListState();
}

class _EditListState extends EditorPageState {
  TextEditingController _nameController;
  InputDecoration _nameDecoration;
  Checklist _list;
  var _dropDown = new List<DropdownMenuItem<Checklist>>();

  void afterParseInit() {
    _nameDecoration = _defaultNameDecoration();
    _list = parseResult.list;
    _nameController = new TextEditingController(text: _list.name);
    _generateDropDown();
  }

  Future deleteList() async {
    var command = parseResult.listColl.remove(_list);
    await persistBookOrUndo(command);
    Navigator.of(context).pop();
  }

  Widget build(BuildContext context) {
    return buildEditorPage(
        _buildBody,
      actions: [
        IconButton(
          icon: Icon(Icons.delete),
          color: ThemeColors.primary,
          onPressed: confirmDeletion(deleteList),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: defaultLR,
      child: ListView(
        children: <Widget>[
          editorElementPadding(
            child: TextField(
              controller: _nameController,
              decoration: _nameDecoration,
              maxLength: maxNameLen,
              onSubmitted: _changeName,
            ),
          ),
          editorElementPadding(
            child: themeRaisedButton(
              child: overflowText(Strings.editItems + " (${_list.length})"),
              onPressed: navigateTo("${widget.path}/items"),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: defaultPad * 3),
            child: Text(Strings.editNextPrimary),
          ),
          editorElementPadding(
            child: themeRaisedButton(
              onPressed: _setNextPrimary,
              child: Text(
                _list.nextPrimary == null
                    ? Strings.noSelection
                    : _list.nextPrimary.name,
              ),
            ),
          ),
          editorElementPadding(
            child: themeRaisedButton(
              child: Text(_alternativeButtonText()),
              onPressed: navigateTo("${widget.path}/alternatives"),
            ),
          ),
        ],
      ),
    );
  }

  void _changeName(String newName) {
    if (newName == '') setState(() => _nameDecoration = _errorNameDecoration());

    var command = _list.rename(newName);

    setState(() {
      _nameDecoration = _defaultNameDecoration();
    });

    persistBookOrUndo(command);
  }

  InputDecoration _defaultNameDecoration() {
    return InputDecoration(hintText: Strings.nameHint);
  }

  InputDecoration _errorNameDecoration() {
    return InputDecoration(
        hintText: Strings.nameHint, errorText: Strings.noNameError);
  }

  void _generateDropDown() {
    _dropDown.clear();
    _dropDown.add(
      new DropdownMenuItem<Checklist>(
        child: overflowText(Strings.noSelection),
        value: null,
      ),
    );
    for (var list in book.normalLists) {
      _dropDown.add(
        new DropdownMenuItem<Checklist>(
          child: overflowText(list.name),
          value: list,
        ),
      );
    }
  }

  Future _setNextPrimary() async {
    var selection = await chooseList(context, book);
    if (selection != null) {
      var list = selection.list;
      var command = _list.setNextPrimary(list);
      setState(() {});
      var success = await io.persistBook(book);
      if (!success) setState(() => command.undo());
    }
  }

  String _alternativeButtonText() {
    return "${Strings.editNextAlternatives} (${_list.nextAlternatives.length})";
  }
}
