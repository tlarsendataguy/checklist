import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:checklist/ui/templates.dart';

typedef void AdditionalInitsCallback(ParsedItems result);

abstract class MyAppPage extends StatefulWidget {
  MyAppPage(this.path, this.onThemeChanged, this.padding);

  final String path;
  final ThemeChangeCallback onThemeChanged;
  final EdgeInsetsGeometry padding;
}

abstract class MyAppPageState extends State<MyAppPage> {
  MyAppPageState();

  bool isLoading = true;

  initPageState(AdditionalInitsCallback additionalInits) {
    ParsePath.parse(widget.path).then((ParsedItems result) {
      setState(() {
        isLoading = false;
        additionalInits(result);
      });
    });
  }

  Widget buildPage({BuildContext context, String title, Widget bodyBuilder(BuildContext context)}) {
    return new Scaffold(
      appBar: themeAppBar(
        title: title,
        onThemeChanged: _themeChanged,
      ),
      body: _getBody(context, bodyBuilder),
    );
  }

  void _themeChanged(bool makeRed) {
    setState(() => widget.onThemeChanged(makeRed));
  }

  Widget _getBody(BuildContext context, Widget body(BuildContext context)) {
    if (isLoading)
      return new Center(
        child: new CupertinoActivityIndicator(),
      );
    else
      return new Padding(
        padding: widget.padding,
        child: body(context),
      );
  }
}
