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
    _createActions();
  }

  AppBar appBar;
  Widget leading;
  List<Widget> actions = [];

  void _createAppBar() {
    appBar = new AppBar(
      backgroundColor: ThemeColors.primary950,
      title: new Text(widget.title),
      leading: leading,
      actions: actions,
    );
  }

  void _createLeading() {
    leading = isLanding()
        ? null
        : new IconButton(
            icon: BackButtonIcon(),
            onPressed: _goBack,
            color: ThemeColors.primary,
          );
  }

  void _createActions() {
    actions.clear();

    if (isLanding()) {
      actions.add(IconButton(
        icon: Icon(Icons.format_paint),
        color: ThemeColors.isRed ? primaryGreen : primaryRed,
        onPressed: _changeTheme,
      ));
    }
  }

  bool isLanding() {
    return widget.path == '/';
  }

  Function navigateTo(String path) {
    return () {
      Navigator.of(context).pushNamed(path);
    };
  }

  void _changeTheme() {
    widget.themeChangeCallback();
    _createLeading();
    _createActions();
    setState(_createAppBar);
  }

  void _goBack() {
    Navigator.of(context).pop();
  }
}
