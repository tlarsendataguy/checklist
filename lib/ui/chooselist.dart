import 'dart:async';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/ui/strings.dart';
import 'package:commandlist/commandlist.dart';
import 'package:flutter/material.dart';

typedef Widget builder(BuildContext context, int index);

class Selection {
  Selection(this.list);
  Checklist list;
}

Future<Selection> chooseList(BuildContext context, Book book) async {
  return await showDialog<Selection>(
    context: context,
    child: new Dialog(
      child: new Column(
        children: <Widget>[
          new Expanded(
            child: new ListView.builder(
              itemBuilder: _normalBuilder(book),
              itemCount: book.normalLists.length + 1,
            ),
          ),
          new Expanded(
            child: new ListView.builder(
              itemBuilder: _emergencyBuilder(book),
              itemCount: book.emergencyLists.length + 1,
            ),
          ),
        ],
      ),
    ),
  );
}

builder _normalBuilder(Book book) {
  return _rootBuilder(book.normalLists);
}

builder _emergencyBuilder(Book book) {
  return _rootBuilder(book.emergencyLists);
}

builder _rootBuilder(CommandList<Checklist> lists) {
  return (BuildContext context, int index) {
    if (index == lists.length) {
      return new FlatButton(
          onPressed: () => Navigator.of(context).pop(new Selection(null)),
          child: new Text(Strings.noSelection));
    }
    var list = lists[index];
    return new FlatButton(
      onPressed: () => Navigator.of(context).pop(new Selection(list)),
      child: new Text(list.name),
    );
  };
}
