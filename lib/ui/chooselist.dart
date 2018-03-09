import 'dart:async';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/ui/strings.dart';
import 'package:commandlist/commandlist.dart';
import 'package:flutter/material.dart';
import 'package:checklist/ui/templates.dart';

typedef Widget Builder(BuildContext context, int index);

class Selection {
  Selection(this.list);
  Checklist list;
}

Future<Selection> chooseList(BuildContext context, Book book,
    {bool haveNoSelection = true}) async {
  return await showDialog<Selection>(
    context: context,
    child: ThemeDialog(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: TabBar(
            tabs: <Widget>[
              Tab(text: Strings.normalLists),
              Tab(text: Strings.emergencyLists),
            ],
          ),
          body: TabBarView(
            children: <Widget>[
              _buildListView(book.normalLists, haveNoSelection),
              _buildListView(book.emergencyLists, haveNoSelection),
            ],
          ),
        ),
      ),
    ),
  );
}

ListView _buildListView(CommandList<Checklist> lists, bool haveNoSelection) {
  int count = lists.length;
  if (haveNoSelection) count++;

  return new ListView.builder(
    itemExtent: 48.0,
    itemBuilder: _rootBuilder(lists),
    itemCount: count,
  );
}

Builder _rootBuilder(CommandList<Checklist> lists) {
  return (BuildContext context, int index) {
    if (index == lists.length) {
      return themeRaisedButton(
          onPressed: () => Navigator.of(context).pop(new Selection(null)),
          child: ListItem1TextRow(Strings.noSelection));
    }
    var list = lists[index];
    return themeRaisedButton(
      onPressed: () => Navigator.of(context).pop(new Selection(list)),
      child: ListItem1TextRow(list.name),
    );
  };
}
