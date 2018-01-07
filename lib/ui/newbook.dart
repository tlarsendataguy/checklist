import 'dart:async';

import 'package:checklist/src/serializer.dart';
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
  InputDecoration _nameDecoration = new InputDecoration();
  bool _creating = false;

  _NewBookState();

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("New book"),
      ),
      body: new Padding(
        padding: new EdgeInsets.all(12.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text("Enter a name for the new book of checklists:"),
            new TextField(
              controller: _name,
              decoration: _nameDecoration,
            ),
            new Center(
              child: new Padding(
                padding: new EdgeInsets.all(32.0),
                child: new RaisedButton(
                  child: _createButtonContent(),
                  onPressed: _createContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createButtonContent() {
    var createBookText = "Create new book";
    if (_creating) {
      return new IntrinsicWidth(
        child: new Row(
          children: <Widget>[
            new Text(createBookText),
            new CupertinoActivityIndicator(),
          ],
        ),
      );
    } else {
      return new Text(createBookText);
    }
  }

  Future _createContainer() async {
    if (_name.text == "") {
      setState(() => _nameDecoration = new InputDecoration(
            errorText: "The name cannot be blank",
          ));
      return;
    }
    setState(() {
      _creating = true;
      _nameDecoration = new InputDecoration();
    });
    var io = new BookIo();
    var book = new Book(_name.text);
    await io.persistBook(book);

    Navigator.of(context).pushReplacementNamed("/${book.id}");
  }
}
