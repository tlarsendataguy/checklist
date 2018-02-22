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

Future<Selection> chooseList(BuildContext context, Book book, {bool haveNoSelection = true}) async {
  return await showDialog<Selection>(
    context: context,
    child: new Dialog(
      child: new DefaultTabController(
        length: 2,
        child: new Container(
          decoration: new BoxDecoration(
            border: new Border.all(color: ThemeColors.primary, width: 1.0),
          ),
          child: new Scaffold(
            appBar: new TabBar(
              tabs: <Widget>[
                new Tab(
                  text: Strings.normalLists,
                ),
                new Tab(
                  text: Strings.emergencyLists,
                )
              ],
            ),
            body: new Column(
              children: <Widget>[
                new Expanded(
                  child: new TabBarView(
                    children: <Widget>[
                      _buildListView(book.normalLists,haveNoSelection),
                      _buildListView(book.emergencyLists, haveNoSelection),
                    ],
                  ),
                ),
                new Row(
                  children: <Widget>[
                    new Expanded(
                      child: themeRaisedButton(
                        onPressed: () => Navigator.of(context).pop(null),
                        child: new Text(Strings.cancel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

ListView _buildListView(CommandList<Checklist> lists, bool haveNoSelection){
  int count = lists.length;
  if (haveNoSelection) count++;

  return new ListView.builder(
    itemBuilder: _rootBuilder(lists),
    itemCount: count,
  );
}

Builder _rootBuilder(CommandList<Checklist> lists) {
  return (BuildContext context, int index) {
    if (index == lists.length) {
      return themeRaisedButton(
          onPressed: () => Navigator.of(context).pop(new Selection(null)),
          child: new Text(Strings.noSelection));
    }
    var list = lists[index];
    return themeRaisedButton(
      onPressed: () => Navigator.of(context).pop(new Selection(list)),
      child: new Text(list.name),
    );
  };
}
