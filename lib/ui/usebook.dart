import 'dart:async';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:checklist/ui/strings.dart';
import 'package:checklist/ui/templates.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:checklist/src/navigator.dart' as nav;

class UseBook extends StatefulWidget {
  UseBook(this.path);

  final String path;

  @override
  State<StatefulWidget> createState() => new UseBookState();
}

class UseBookState extends State<UseBook> {
  UseBookState();

  bool isLoading = true;
  bool errorLoading = false;
  Book book;
  nav.Navigator navigator;
  double opacity = 1.0;
  final int fadeDelay = 85;

  @override
  void initState() {
    super.initState();

    ParsePath.parse(widget.path).then<ParsedItems>((items) {
      if (mounted) {
        setState(() {
          if (items.result == ParseResult.UseBook) book = items.book;
          navigator = new nav.Navigator(book);
          isLoading = false;
        });
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorLoading = true;
        });
      }
    });
  }

  Future<bool> willPop() {
    if (navigator.canGoBack) {
      fadeTransition(()=>navigator.goBack())();
      return new Future<bool>.value(false);
    }
    return new Future<bool>.value(true);
  }

  Widget _body() {
    var current = navigator.currentItem;
    if (current == null) {
      return Text("End of checklist");
    } else if (current.isBranch) {
      return _questionItem();
    } else {
      return _checkItem();
    }
  }

  Widget _questionItem() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Center(
            child: Text(
              navigator.currentItem.toCheck,
              textScaleFactor: 2.5,
            ),
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: _yesNoButton(true),
            ),
            Expanded(
              flex: 1,
              child: _yesNoButton(false),
            )
          ],
        ),
      ],
    );
  }

  Widget _yesNoButton(bool branch) {
    return Container(
      height: 88.0,
      padding: EdgeInsets.all(4.0),
      child: OutlineButton(
        child: Text(
          branch ? Strings.yes : Strings.no,
          textScaleFactor: 1.8,
        ),
        onPressed: setMoveNext(branch),
        textColor: ThemeColors.primary,
        shape: StadiumBorder(),
        disabledBorderColor: ThemeColors.primary,
        highlightedBorderColor: ThemeColors.primary,
        borderSide: BorderSide(color: ThemeColors.primary, width: 5.0),
        color: ThemeColors.primary,
      ),
    );
  }

  Widget _checkItem() {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 48.0),
                child: Center(
                  child: Text(
                    navigator.currentItem.toCheck,
                    textScaleFactor: 2.5,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.fromLTRB(8.0, 48.0, 8.0, 8.0),
                child: Center(
                  child: Text(
                    navigator.currentItem.action,
                    textScaleFactor: 2.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        Center(
          child: Container(
            color: ThemeColors.primary,
            height: 3.0,
          ),
        ),
        Center(
          child: Container(
            width: 80.0,
            height: 80.0,
            color: ThemeColors.black,
            child: OutlineButton(
              child: Icon(
                Icons.check,
                size: 40.0,
              ),
              onPressed: setMoveNext(),
              shape: CircleBorder(),
              textColor: ThemeColors.primary,
              disabledBorderColor: ThemeColors.primary,
              highlightedBorderColor: ThemeColors.primary,
              borderSide: BorderSide(color: ThemeColors.primary, width: 5.0),
              color: ThemeColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Function setMoveNext([bool branch]){
    return fadeTransition(()=>navigator.moveNext(branch: branch));
  }

  Function fadeTransition(Function stateChangeAction) {
    return () async {
      setState(() {
        opacity = 0.0;
      });
      await Future.delayed(Duration(milliseconds: fadeDelay),stateChangeAction);
      setState(() {
        opacity = 1.0;
      });

    };
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return new CupertinoActivityIndicator();
    else if (errorLoading)
      return new Text("Error");
    else
      return new WillPopScope(
        onWillPop: willPop,
        child: Scaffold(
          appBar: new AppBar(title: new Text(navigator.currentList.name)),
          body: AnimatedOpacity(
            duration: Duration(milliseconds: fadeDelay),
            opacity: opacity,
            child: _body(),
          ),
        ),
      );
  }
}
