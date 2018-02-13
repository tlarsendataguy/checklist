import 'package:checklist/src/parsepath.dart';
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

  Route<Null> _getRoute(RouteSettings settings) {
    //Get the home page
    if (settings.name == '/') {
      return new MaterialPageRoute<Null>(
        settings: settings,
        maintainState: false,
        builder: (BuildContext context) => new Landing(setColor),
      );
    }

    final List<String> path = settings.name.split('/');

    //First character in path must be a forward slash
    if (path[0] != '') {
      return null;
    }

    //Get the create new book page
    if (path[1] == 'newBook') {
      if (path.length != 2) return null;
      return new MaterialPageRoute(
        settings: settings,
        maintainState: false,
        builder: (BuildContext context) => new NewBook(),
      );
    }

    if (_isBook(path)) {
      //Get the edit book page
      return new MaterialPageRoute(
        settings: settings,
        maintainState: false,
        builder: (BuildContext context) => new EditBook(settings.name),
      );
    }

    if (_isBookBranch(path)) {
      return new MaterialPageRoute(
        settings: settings,
        maintainState: false,
        builder: (BuildContext context) => new EditBookBranch(settings.name),
      );
    }

    if (_isList(path)) {
      return new MaterialPageRoute(
        settings: settings,
        maintainState: false,
        builder: (BuildContext context) => new EditList(settings.name),
      );
    }

    return null;
  }

  bool _isList(List<String> path) {
    return path.length == 4 &&
        _isBookBranch(path.sublist(0, 3)) &&
        ParsePath.stringIsId(path[3]);
  }

  bool _isBookBranch(List<String> path) {
    return path.length == 3 &&
        _isBook(path.sublist(0, 2)) &&
        ParsePath.stringIsListType(path[2]);
  }

  bool _isBook(List<String> path) {
    return path.length == 2 && ParsePath.stringIsId(path[1]);
  }
}
