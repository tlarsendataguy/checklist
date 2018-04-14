import 'dart:async';

import 'package:checklist/ui/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:checklist/ui/templates.dart';
import 'package:checklist/ui/editorpage.dart';

class EditBook extends EditorPage {
  EditBook(String path)
      : super(
          path: path,
          title: Strings.editBookTitle,
        );

  _EditBookState createState() => new _EditBookState();
}

class _EditBookState extends EditorPageState {
  TextEditingController _nameController;
  InputDecoration _nameDecoration;

  void afterParseInit() {
    _nameDecoration = _defaultDecoration();
    _nameController = new TextEditingController(text: book.name);
  }

  Widget build(BuildContext context) {
    return buildEditorPage(_buildBody);
  }

  Widget _buildBody() {
    return Padding(
      padding: defaultLR,
      child: ListView(
        children: <Widget>[
          editorElementPadding(
            child: TextField(
              onSubmitted: _changeName,
              controller: _nameController,
              decoration: _nameDecoration,
              maxLength: maxNameLen,
            ),
          ),
          editorElementPadding(
            child: themeRaisedButton(
              child: Text(
                  Strings.editNormalLists + " (${book.normalLists.length})"),
              onPressed: navigateTo("${widget.path}/normal"),
            ),
          ),
          editorElementPadding(
            child: themeRaisedButton(
              child: Text(Strings.editEmergencyLists +
                  " (${book.emergencyLists.length})"),
              onPressed: navigateTo("${widget.path}/emergency"),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _defaultDecoration() {
    return new InputDecoration(
      hintText: Strings.nameHint,
    );
  }

  Future _changeName(String newName) async {
    if (newName == "") {
      setState(() {
        _nameDecoration = new InputDecoration(
          errorText: Strings.noNameError,
          hintText: Strings.nameHint,
        );
      });
      return;
    }

    setState(() {
      _nameDecoration = _defaultDecoration();
    });
    book.changeName(newName);
    await io.persistBook(book);
  }
}
