import 'package:checklist/src/checklist.dart';
import 'package:checklist/ui/strings.dart';
import 'package:commandlist/commandlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:checklist/src/book.dart';

class EditList extends StatefulWidget{
  final String path;

  EditList(this.path);

  createState() => new _EditListState();
}

class _EditListState extends State<EditList>{
  TextEditingController _toCheckController;
  TextEditingController _actionController;
  InputDecoration _toCheckDecoration;
  InputDecoration _actionDecoration;
  bool _isLoading = true;

  initState(){
    super.initState();
    _toCheckDecoration = _defaultToCheckDecoration();
    _actionDecoration = _defaultActionDecoration();
    _toCheckController = new TextEditingController();
    _actionController = new TextEditingController();

    ParsePath.parseBook(widget.path).then((Book parsedBook){
      setState((){
        _isLoading = false;
      });
    });

  }

  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(Strings.editList),
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
      return new Column(
        children: <Widget>[
          new Expanded(
            child: new ListView(
              children: <Widget>[
                new Text("Hello world!"),
              ],
            ),
          ),
          new Row(
            children: <Widget>[
              new Column(
                children: <Widget>[
                  new TextField(
                    controller: _toCheckController,
                    decoration: _toCheckDecoration,
                  ),
                  new TextField(
                    controller: _actionController,
                    decoration: _actionDecoration,
                  )
                ],
              ),
              new RaisedButton(

                onPressed: null,
              )
            ],
          ),
        ],
      );
  }

  InputDecoration _defaultToCheckDecoration(){
    return new InputDecoration(hintText: Strings.toCheckHint);
  }

  InputDecoration _defaultActionDecoration(){
    return new InputDecoration(hintText: Strings.actionHint);
  }
}