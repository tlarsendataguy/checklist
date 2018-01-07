import 'package:checklist/src/checklist.dart';
import 'package:commandlist/commandlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:checklist/src/book.dart';

class EditBookBranch extends StatefulWidget{
  final String path;

  EditBookBranch(this.path);

  createState() => new _EditBookBranchState();
}

class _EditBookBranchState extends State<EditBookBranch>{
  bool _isLoading = true;
  String _listType;
  CommandList<Checklist> _lists;

  initState(){
    super.initState();
    ParsePath.parseBook(widget.path).then((Book parsedBook){
      setState((){
        List<String> elements = widget.path.split('/');
        _listType = elements[elements.length - 1];
        if (_listType == 'normal')
          _lists = parsedBook.normalLists;
        else
          _lists = parsedBook.emergencyLists;
        _isLoading = false;
      });
    });

  }

  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Edit $_listType checklists"),
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
      return new Text(_listType);
  }
}