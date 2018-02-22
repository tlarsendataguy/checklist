import 'package:checklist/src/parsepath.dart';
import 'package:checklist/ui/editalternatives.dart';
import 'package:checklist/ui/editbook.dart';
import 'package:checklist/ui/editbookbranch.dart';
import 'package:checklist/ui/edititems.dart';
import 'package:checklist/ui/strings.dart';
import 'package:flutter/material.dart';
import 'package:checklist/ui/landing.dart';
import 'package:checklist/ui/newbook.dart';
import 'package:checklist/ui/editlist.dart';
import 'package:checklist/ui/templates.dart';

typedef MaterialPageRoute RouteBuilder(Widget builder);

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp>{

  ThemeData theme = ThemeColors.theme;

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: Strings.appTitle,
      theme: ThemeColors.theme,
      onGenerateRoute: _getRoute,
    );
  }

  void setColor(bool makeRed){
    var colorFunc = makeRed ? ThemeColors.setRed : ThemeColors.setGreen;
    setState(colorFunc);
  }

  Route _getRoute(RouteSettings settings) {
    var path = settings.name;
    var result = ParsePath.validate(path);
    var router = _buildRouter(settings);

    switch (result){
      case ParseResult.Home:
        return router(new Landing(setColor));
      case ParseResult.NewBook:
        return router(new NewBook(setColor));
      case ParseResult.Book:
        return router(new EditBook(path,setColor));
      case ParseResult.NormalLists:
      case ParseResult.EmergencyLists:
        return router(new EditBookBranch(path,setColor));
      case ParseResult.List:
        return router(new EditList(path,setColor));
      case ParseResult.Alternatives:
        return router(new EditAlternatives(path,setColor));
      case ParseResult.Items:
        return router(new EditItems(path,setColor));
      default:
        return null;
    }
  }

  RouteBuilder _buildRouter(RouteSettings settings){
    return (Widget builder){
      return new MaterialPageRoute(
        settings: settings,
        maintainState: false,
        builder: (BuildContext context) => builder,
      );
    };
  }
}
