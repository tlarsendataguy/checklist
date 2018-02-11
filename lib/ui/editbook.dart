import 'dart:async';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/bookio.dart';
import 'package:checklist/ui/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:checklist/ui/templates.dart';

class EditBook extends StatefulWidget {
  final String path;

  EditBook(this.path);

  _EditBookState createState() => new _EditBookState();
}

class _EditBookState extends State<EditBook> {
  BookIo _io = new BookIo();
  bool _isLoading = true;
  Book _book;
  TextEditingController _nameController;
  InputDecoration _nameDecoration;

  _EditBookState();

  initState(){
    super.initState();
    ParsePath.parseBook(widget.path).then((Book parsedBook){
      setState((){
        _book = parsedBook;
        _isLoading = false;
        _nameDecoration = _defaultDecoration();
        _nameController = new TextEditingController(text: _book.name);
      });
    });
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Strings.editBookTitle),
      ),
      body: _getBody(context),
    );
  }

  Widget _getBody(BuildContext context){
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
              onSubmitted: _changeName,
                controller: _nameController,
              decoration: _nameDecoration,
            ),
      ),
            editorElementPadding(
              child: new RaisedButton(
                child: new Text(Strings.editNormalLists),
                onPressed: () =>
                    Navigator.of(context).pushNamed("${widget.path}/normal"),
              ),
            ),
            editorElementPadding(
              child: new RaisedButton(
                child: new Text(Strings.editEmergencyLists),
                onPressed:  () =>
                    Navigator.of(context).pushNamed("${widget.path}/emergency"),
              ),
            ),
          ],
        ),
      );
  }

  InputDecoration _defaultDecoration(){
    return new InputDecoration(
      hintText: Strings.nameHint,
    );
  }

  Future _changeName(String newName) async {
    if (newName == ""){
      setState((){
        _nameDecoration = new InputDecoration(
          errorText: Strings.noNameError,
          hintText: Strings.nameHint,
        );
      });
      return;
    }

    setState((){
      _nameDecoration = _defaultDecoration();
    });
    _book.changeName(newName);
    await _io.persistBook(_book);
  }
}
