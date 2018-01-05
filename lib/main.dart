import 'package:checklist/ui/editBook.dart';
import 'package:flutter/material.dart';
import 'package:checklist/ui/landing.dart';
import 'package:checklist/ui/newbook.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Checklist App',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: _getRoute,
    );
  }

  Route<Null> _getRoute(RouteSettings settings){
    //Get the home page
    if (settings.name == '/'){
      return new MaterialPageRoute<Null>(
        settings: settings,
        maintainState: false,
        builder: (BuildContext context) => new Landing(),
      );
    }

    final List<String> path = settings.name.split('/');

    //First character in path must be a forward slash
    if (path[0] != ''){
      return null;
    }

    //Get the create new book page
    if (path[1] == 'newBook'){
      if (path.length != 2) return null;
      return new MaterialPageRoute(
        settings: settings,
          maintainState: false,
          builder: (BuildContext context) => new NewBook(),
      );
    }

    const String idPattern = "[0-9a-f]{14}";
    if (path[1].contains(new RegExp(idPattern))){
      //Get the edit book page
      if (path.length == 2)
        return new MaterialPageRoute(
          settings: settings,
          maintainState: false,
          builder: (BuildContext context) => new EditBook(settings.name),
        );
    }

    return null;
  }
}
