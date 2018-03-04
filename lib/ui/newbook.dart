import 'dart:async';

import 'package:checklist/src/mobilediskwriter.dart';
import 'package:checklist/ui/navigationpage.dart';
import 'package:checklist/ui/strings.dart';
import 'package:checklist/ui/templates.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:checklist/src/book.dart';
import 'package:checklist/src/bookio.dart';

class NewBook extends NavigationPage {
  NewBook(String path, ThemeChangeCallback onThemeChanged)
      : super(
          title: Strings.newBookTitle,
          path: path,
          onThemeChanged: onThemeChanged,
        );

  _NewBookState createState() => new _NewBookState();
}

class _NewBookState extends NavigationPageState {

  TextEditingController _name = new TextEditingController();
  InputDecoration _nameDecoration = _defaultDecoration();
  bool _creating = false;

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Padding(
        padding: pagePadding,
        child: ListView(
          children: <Widget>[
            editorElementPadding(
              child: TextField(
                controller: _name,
                decoration: _nameDecoration,
              ),
            ),
            editorElementPadding(
              child: themeRaisedButton(
                child: _createButtonContent(),
                onPressed: _createContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createButtonContent() {
    var text = Text(Strings.newBookButton);
    if (_creating) {
      return IntrinsicWidth(
        child: Row(
          children: <Widget>[
            text,
            CupertinoActivityIndicator(),
          ],
        ),
      );
    } else {
      return text;
    }
  }

  Future _createContainer() async {
    if (_name.text == "") {
      setState(() => _nameDecoration = new InputDecoration(
            errorText: Strings.noNameError,
            hintText: Strings.nameHint,
          ));
      return;
    }
    setState(() {
      _creating = true;
      _nameDecoration = _defaultDecoration();
    });
    var io = new BookIo(writer: new MobileDiskWriter());
    var book = new Book(name: _name.text);
    await io.persistBook(book);

    navigateTo("/${book.id}")();
  }

  static InputDecoration _defaultDecoration() {
    return new InputDecoration(
      hintText: Strings.nameHint,
    );
  }
}
