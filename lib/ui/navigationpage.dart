import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'templates.dart';

abstract class NavigationPage extends StatefulWidget {
  NavigationPage({
    @required this.title,
    @required this.path,
    this.themeChangeCallback,
  });

  final String path;
  final String title;
  final Function themeChangeCallback;
}

abstract class NavigationPageState extends State<NavigationPage> {
  NavigationPageState();

  @mustCallSuper
  initState() {
    super.initState();

    _createLeading();
    _createAppBar();
  }

  AppBar appBar;
  Widget leading;

  void _createAppBar() {
    appBar = new AppBar(
      backgroundColor: ThemeColors.primary950,
      title: new Text(widget.title),
      leading: leading,
    );
  }

  void _createLeading() {
    leading = (widget.path == '/')
        ? new IconButton(
            icon: Icon(Icons.format_paint),
            color: ThemeColors.isRed ? primaryGreen : primaryRed,
            onPressed: _changeTheme,
          )
        : new IconButton(
            icon: BackButtonIcon(),
            onPressed: _goBack,
            color: ThemeColors.primary,
          );
  }

  Function navigateTo(String path) {
    return () {
      Navigator.of(context).pushNamed(path);
    };
  }

  void _changeTheme() {
    widget.themeChangeCallback();
    _createLeading();
    setState(_createAppBar);
  }

  void _goBack() {
    Navigator.of(context).pop();
  }
}
