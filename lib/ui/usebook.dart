import 'dart:async';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/mobilediskwriter.dart';
import 'package:checklist/src/navigatorio.dart';
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
  NavigatorIo io;
  double opacity = 1.0;
  final int fadeDelay = 85;
  final smallScale = 1.8;
  final largeScale = 2.5;
  final midScale = 2.0;

  @override
  void initState() {
    super.initState();

    ParsePath.parse(widget.path).then<ParsedItems>((items) async {
      if (mounted) {
        if (items.result == ParseResult.UseBook) book = items.book;
        navigator = new nav.Navigator(book);
        io = new NavigatorIo(navigator, MobileDiskWriter());
        await io.retrieve();

        setState(() {
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
      fadeTransition(() => navigator.goBack())();
      return new Future<bool>.value(false);
    }
    return new Future<bool>.value(true);
  }

  Widget _body() {
    var current = navigator.currentItem;
    if (current == null) {
      if (_isFinished()) {
        return _done();
      } else {
        return _selectNextList();
      }
    } else if (current.isBranch) {
      return _questionItem();
    } else {
      return _checkItem();
    }
  }

  Widget _done() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            Strings.completed,
            textScaleFactor: smallScale,
          ),
        ),
        Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: _button(
                      child: Text(
                        Strings.exit,
                        textScaleFactor: smallScale,
                      ),
                      onPressed: () async {
                        io.delete();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: _button(
                      child: Text(
                        Strings.restart,
                        textScaleFactor: smallScale,
                      ),
                      onPressed:
                          fadeTransition(() => navigator = nav.Navigator(book)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _isFinished() {
    var list = navigator.currentList;
    if (list == null ||
        (list.nextPrimary == null && list.nextAlternatives.length == 0))
      return true;
    else
      return false;
  }

  Widget _selectNextList() {
    var list = navigator.currentList;
    var widgets = <Widget>[];

    if (list.nextPrimary != null) {
      widgets.add(
        Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Center(
            child: Text(
              Strings.next,
              textScaleFactor: smallScale,
            ),
          ),
        ),
      );
      widgets.add(Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
              child: _button(
                child: Text(
                  list.nextPrimary.name,
                  textScaleFactor: midScale,
                ),
                onPressed: setNextList(list.nextPrimary),
              ),
            ),
          )
        ],
      ));
    }

    if (list.nextAlternatives.length > 0) {
      widgets.add(
        Padding(
          padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Center(
            child: Text(
              Strings.alternatives,
              textScaleFactor: smallScale,
            ),
          ),
        ),
      );
      for (var altList in list.nextAlternatives) {
        widgets.add(
          Padding(
            padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
            child: _button(
              child: Text(
                altList.name,
                textScaleFactor: midScale,
              ),
              onPressed: setNextList(altList),
            ),
          ),
        );
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ListView(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          children: widgets,
        ),
      ],
    );
  }

  Widget _questionItem() {
    return _itemWidget(
      navigator.currentItem.toCheck,
      "",
      child: Center(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.0, 0.0, 8.0, 0.0),
                child: _yesNoButton(true),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(8.0, 0.0, 16.0, 0.0),
                child: _yesNoButton(false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _yesNoButton(bool branch) {
    return _button(
      child: Text(
        branch ? Strings.yes : Strings.no,
        textScaleFactor: smallScale,
      ),
      onPressed: setMoveNext(branch),
    );
  }

  Widget _button(
      {Widget child, double width, double height = 80.0, Function onPressed}) {
    return Container(
      height: height,
      width: width,
      color: ThemeColors.black,
      child: OutlineButton(
        child: child,
        onPressed: onPressed,
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
    return _itemWidget(
      navigator.currentItem.toCheck,
      navigator.currentItem.action,
      child: Center(
        child: _button(
          child: Icon(Icons.check, size: 40.0),
          width: 80.0,
          onPressed: setMoveNext(),
        ),
      ),
    );
  }

  Widget _itemWidget(String topText, String bottomText, {Widget child}) {
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
                    topText,
                    textScaleFactor: largeScale,
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
                    bottomText,
                    textScaleFactor: largeScale,
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
        child,
      ],
    );
  }

  Function setNextList(Checklist list) {
    return fadeTransition(() {
      navigator.changeList(list);
    });
  }

  Function setMoveNext([bool branch]) {
    return fadeTransition(() {
      navigator.moveNext(branch: branch);
    });
  }

  Function fadeTransition(Function stateChangeAction) {
    return () async {
      setState(() {
        opacity = 0.0;
      });
      await Future.delayed(
          Duration(milliseconds: fadeDelay), stateChangeAction);
      await io.persist();
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
    else {
      String title;
      if (navigator.currentList == null) {
        title = navigator.book.name;
      } else {
        title = navigator.currentList.name;
      }
      return new WillPopScope(
        onWillPop: willPop,
        child: Scaffold(
          appBar: new AppBar(title: new Text(title)),
          body: AnimatedOpacity(
            duration: Duration(milliseconds: fadeDelay),
            opacity: opacity,
            child: _body(),
          ),
        ),
      );
    }
  }
}
