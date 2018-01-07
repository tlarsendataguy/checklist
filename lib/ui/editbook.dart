import 'package:checklist/src/book.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:checklist/src/parsepath.dart';

class EditBook extends StatefulWidget {
  final String path;

  EditBook(this.path);

  _EditBookState createState() => new _EditBookState();
}

class _EditBookState extends State<EditBook> {
  bool _isLoading = true;
  Book _book;
  TextEditingController _nameController;

  _EditBookState();

  initState(){
    super.initState();
    ParsePath.parseBook(widget.path).then((Book parsedBook){
      setState((){
        _book = parsedBook;
        _isLoading = false;
        _nameController = new TextEditingController(text: _book.name);
      });
    });
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Edit book"),
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
        padding: new EdgeInsets.all(12.0),
        child: new ListView(
          children: <Widget>[
            new Text("Name:"),
            new TextField(controller: _nameController),
            new Padding(
              padding: new EdgeInsets.all(32.0),
              child: new RaisedButton(
                child: new Text("Edit normal checklists"),
                onPressed: () =>
                    Navigator.of(context).pushNamed("${widget.path}/normal"),
              ),
            ),
            new Padding(
              padding: new EdgeInsets.fromLTRB(32.0, 0.0, 32.0, 32.0),
              child: new RaisedButton(
                child: new Text("Edit emergency checklists"),
                onPressed:  () =>
                    Navigator.of(context).pushNamed("${widget.path}/emergency"),
              ),
            ),
          ],
        ),
      );
  }
}
