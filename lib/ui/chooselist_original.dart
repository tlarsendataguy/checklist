import 'dart:async';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/ui/strings.dart';
import 'package:flutter/material.dart';

class Selection {
  Selection(this.list);
  Checklist list;
}

Future<Selection> chooseList(BuildContext context, Book book) async {
  return await showDialog<Selection>(
    context: context,
    child: Dialog(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) => buildBody(context, index, book),
              itemCount: book.normalLists.length + 1,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildBody(BuildContext context, int index, Book book) {
  var lists = book.normalLists;
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
}
