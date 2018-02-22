import 'dart:async';

import 'package:checklist/ui/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:checklist/ui/templates.dart';
import 'package:checklist/ui/editorpage.dart';

class EditBook extends EditorPage {
  EditBook(String path, ThemeChangeCallback onThemeChanged)
      : super(path, onThemeChanged, pagePadding);

  _EditBookState createState() => new _EditBookState();
}

class _EditBookState extends EditorPageState {
  _EditBookState();

  TextEditingController _nameController;
  InputDecoration _nameDecoration;

  initState() {
    super.initState();
    initEditorState((result) {
      _nameDecoration = _defaultDecoration();
      _nameController = new TextEditingController(text: book.name);
    });
  }

  Widget build(BuildContext context) {
    return buildPage(
      context: context,
      title: Strings.editBookTitle,
      bodyBuilder: _getBody,
    );
  }

  Widget _getBody(BuildContext context) {
    return new ListView(
      children: <Widget>[
        editorElementPadding(
          child: new TextField(
            onSubmitted: _changeName,
            controller: _nameController,
            decoration: _nameDecoration,
          ),
        ),
        editorElementPadding(
          child: themeRaisedButton(
            child: new Text(Strings.editNormalLists),
            onPressed: () =>
                Navigator.of(context).pushNamed("${widget.path}/normal"),
          ),
        ),
        editorElementPadding(
          child: themeRaisedButton(
            child: new Text(Strings.editEmergencyLists),
            onPressed: () =>
                Navigator.of(context).pushNamed("${widget.path}/emergency"),
          ),
        ),
      ],
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
