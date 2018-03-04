import 'package:checklist/ui/templates.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

abstract class NavigationPage extends StatefulWidget {
  NavigationPage({
    @required this.title,
    @required this.path,
    @required this.onThemeChanged,
  });

  final String path;
  final ThemeChangeCallback onThemeChanged;
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

    appBar = themeAppBar(
      title: widget.title,
      onThemeChanged: _themeChanged,
      leading: leading,
    );
  }

  AppBar appBar;
  Widget leading;

  void _themeChanged(bool makeRed) {
    setState(() => widget.onThemeChanged(makeRed));
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
