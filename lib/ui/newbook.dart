import 'dart:async';

import 'package:checklist/src/serializer.dart';
import 'package:checklist/ui/strings.dart';
import 'package:checklist/ui/templates.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:checklist/src/book.dart';
import 'package:checklist/ui/editbook.dart';
import 'package:checklist/src/bookio.dart';

class NewBook extends StatefulWidget {
  NewBook();

  _NewBookState createState() => new _NewBookState();
}

class _NewBookState extends State<NewBook> {
  TextEditingController _name = new TextEditingController();
  InputDecoration _nameDecoration = _defaultDecoration();
  bool _creating = false;
  static const String _nameHint = "Name";

  _NewBookState();

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Strings.newBookTitle),
      ),
      body: new Padding(
        padding: pagePadding,
        child: new ListView(
          children: <Widget>[
            editorElementPadding(
              child: new TextField(
                controller: _name,
                decoration: _nameDecoration,
              ),
            ),
            editorElementPadding(
              child: new RaisedButton(
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
    var text = new Text(Strings.newBookButton);
    if (_creating) {
      return new IntrinsicWidth(
        child: new Row(
          children: <Widget>[
            text,
            new CupertinoActivityIndicator(),
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
            errorText: "The name cannot be blank",
            hintText: _nameHint,
          ));
      return;
    }
    setState(() {
      _creating = true;
      _nameDecoration = _defaultDecoration();
    });
    var io = new BookIo();
    var book = new Book(name: _name.text);
    await io.persistBook(book);

    Navigator.of(context).pushReplacementNamed("/${book.id}");
  }

  static InputDecoration _defaultDecoration() {
    return new InputDecoration(
      hintText: _nameHint,
    );
  }
}
