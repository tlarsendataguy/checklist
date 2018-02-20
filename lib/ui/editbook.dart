import 'dart:async';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/bookio.dart';
import 'package:checklist/ui/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:checklist/ui/templates.dart';
import 'package:checklist/ui/editorpage.dart';

class EditBook extends MyAppPage {
  EditBook(String path, ThemeChangeCallback onThemeChanged)
      : super(path, onThemeChanged, pagePadding);

  _EditBookState createState() => new _EditBookState();
}

class _EditBookState extends MyAppPageState {
  _EditBookState();

  BookIo _io = new BookIo();
  Book _book;
  TextEditingController _nameController;
  InputDecoration _nameDecoration;

  initState() {
    super.initState();
    initPageState((result) {
      _book = result.book;
      _nameDecoration = _defaultDecoration();
      _nameController = new TextEditingController(text: _book.name);
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
    _book.changeName(newName);
    await _io.persistBook(_book);
  }
}
