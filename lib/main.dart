import 'package:checklist/src/parsepath.dart';
import 'package:checklist/ui/editalternatives.dart';
import 'package:checklist/ui/editbook.dart';
import 'package:checklist/ui/editbookbranch.dart';
import 'package:checklist/ui/strings.dart';
import 'package:flutter/material.dart';
import 'package:checklist/ui/landing.dart';
import 'package:checklist/ui/newbook.dart';
import 'package:checklist/ui/editlist.dart';
import 'package:checklist/ui/templates.dart';

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

    switch (result){
      case ParseResult.Home:
        return _buildRoute(settings, new Landing(setColor));
      case ParseResult.NewBook:
        return _buildRoute(settings, new NewBook(setColor));
      case ParseResult.Book:
        return _buildRoute(settings, new EditBook(path,setColor));
      case ParseResult.NormalLists:
      case ParseResult.EmergencyLists:
        return _buildRoute(settings, new EditBookBranch(path,setColor));
      case ParseResult.List:
        return _buildRoute(settings, new EditList(path,setColor));
      case ParseResult.Alternatives:
        return _buildRoute(settings, new EditAlternatives(path,setColor));
      default:
        return null;
    }
  }

  MaterialPageRoute _buildRoute(RouteSettings settings, Widget builder){
    return new MaterialPageRoute(
      settings: settings,
      maintainState: false,
      builder: (BuildContext context) => builder,
    );
  }
}
