import 'package:checklist/ui/editnote.dart';
import 'package:checklist/ui/pathroute.dart';
import 'package:checklist/ui/usebook.dart';
import 'package:flutter/material.dart';

import 'package:checklist/src/mobilediskwriter.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:checklist/ui/editalternatives.dart';
import 'package:checklist/ui/editbook.dart';
import 'package:checklist/ui/editbookbranch.dart';
import 'package:checklist/ui/edititems.dart';
import 'package:checklist/ui/strings.dart';
import 'package:checklist/ui/landing.dart';
import 'package:checklist/ui/newbook.dart';
import 'package:checklist/ui/editlist.dart';
import 'package:checklist/ui/templates.dart';
import 'package:checklist/ui/edititem.dart';
import 'package:checklist/ui/editnotes.dart';

typedef MaterialPageRoute RouteBuilder(Widget builder);

void main() {
  ParsePath.setWriter(new MobileDiskWriter());
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp>{
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: Strings.appTitle,
      theme: ThemeColors.theme,
      onGenerateRoute: _getRoute,
    );
  }

  Route _getRoute(RouteSettings settings) {
    var path = settings.name;
    var result = ParsePath.validate(path);
    var router = _buildRouter(settings);

    switch (result){
      case ParseResult.Home:
        return router(new Landing(path,changeTheme));
      case ParseResult.NewBook:
        return router(new NewBook(path));
      case ParseResult.UseBook:
        return router(new UseBook(path));
      case ParseResult.Book:
        return router(new EditBook(path));
      case ParseResult.NormalLists:
      case ParseResult.EmergencyLists:
        return router(new EditBookBranch(path));
      case ParseResult.List:
        return router(new EditList(path));
      case ParseResult.Alternatives:
        return router(new EditAlternatives(path));
      case ParseResult.Items:
      case ParseResult.TrueBranch:
      case ParseResult.FalseBranch:
        return router(new EditItems(path));
      case ParseResult.Item:
        return router(new EditItem(path));
      case ParseResult.Notes:
        return router(new EditNotes(path));
      case ParseResult.Note:
        return router(new EditNote(path));
      default:
        return null;
    }
  }

  RouteBuilder _buildRouter(RouteSettings settings){
    int level;
    String path = settings.name;

    if (path == '/')
      level = 0;
    else
      level = path.split('/').length - 1;

    return (Widget builder){
      return new PathRoute(
        settings: settings,
        level: level,
        builder: (BuildContext context) => builder,
      );
    };
  }

  void changeTheme(){
    setState(ThemeColors.toggleTheme);
  }
}
