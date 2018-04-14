import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

abstract class NavigationPage extends StatefulWidget {
  NavigationPage({
    @required this.title,
    @required this.path,
  });

  final String path;
  final String title;
}

abstract class NavigationPageState extends State<NavigationPage> {
  NavigationPageState();

  @mustCallSuper
  initState() {
    super.initState();

    leading = (widget.path == '/')
        ? null
        : new IconButton(
            icon: BackButtonIcon(),
            onPressed: _goBack,
          );

    _createAppBar();
  }

  AppBar appBar;
  Widget leading;

  void _createAppBar(){
    appBar = new AppBar(
      title: new Text(widget.title),
      leading: leading,
    );
  }

  Function navigateTo(String path) {
    return () {
      Navigator.of(context).pushNamed(path);
    };
  }

  void _goBack(){
    Navigator.of(context).pop();
  }
}
