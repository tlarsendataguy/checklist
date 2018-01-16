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
  Checklist _list;

  initState(){
    super.initState();
    _toCheckDecoration = _defaultToCheckDecoration();
    _actionDecoration = _defaultActionDecoration();
    _toCheckController = new TextEditingController();
    _actionController = new TextEditingController();

    ParsePath.parseList(widget.path).then((Checklist parsedList){
      setState((){
        _list = parsedList;
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
      return new Padding(
        padding: new EdgeInsets.all(12.0),
        child:  new ListView(
              children: <Widget>[
                new Text(_list.name),
              ],
            ),
          );
  }

  InputDecoration _defaultToCheckDecoration(){
    return new InputDecoration(hintText: Strings.toCheckHint);
  }

  InputDecoration _defaultActionDecoration(){
    return new InputDecoration(hintText: Strings.actionHint);
  }
}