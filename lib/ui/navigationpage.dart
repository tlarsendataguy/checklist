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

  AppBar appBar({List<Widget> actions}){
    return new AppBar(
      backgroundColor: ThemeColors.primary950,
      title: new Text(widget.title),
      leading: isLanding()
          ? null
          : new IconButton(
        icon: BackButtonIcon(),
        onPressed: _goBack,
        color: ThemeColors.primary,
      ),
      actions: actions,
    );
  }

  bool isLanding() {
    return widget.path == '/';
  }

  Function navigateTo(String path) {
    return () {
      Navigator.of(context).pushNamed(path);
    };
  }

  void _goBack() {
    Navigator.of(context).pop();
  }
}
