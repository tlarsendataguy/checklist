import 'dart:async';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/mobilediskwriter.dart';
import 'package:checklist/src/navigatorio.dart';
import 'package:checklist/src/note.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:checklist/ui/strings.dart';
import 'package:checklist/ui/templates.dart';
import 'package:commandlist/commandlist.dart';
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
  static const double _noteButtonWidth = 50.0;
  List<Note> _notes;

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

  Future<bool> willPop() async {
    if (navigator.canGoBack) {
      fadeTransition(() => navigator.goBack())();
      return new Future<bool>.value(false);
    }
    await io.delete();
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
                      onPressed: _exitUseBook,
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

  _exitUseBook() async {
    await io.delete();
    Navigator.of(context).pop();
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

    return Center(
      child: ListView(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        children: [
          Column(
            children: widgets,
          ),
        ],
      ),
    );
  }

  Widget _questionItem() {
    return _itemWidget(
      navigator.currentItem.toCheck,
      "",
      centerRow: Center(
        child: Padding(
          padding: EdgeInsets.only(left: _hasNotes() ? _noteButtonWidth : 0.0),
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

  bool _hasNotes() {
    var currentItem = navigator.currentItem;
    return currentItem != null && currentItem.notes.length > 0;
  }

  Widget _checkItem() {
    return _itemWidget(
      navigator.currentItem.toCheck,
      navigator.currentItem.action,
      centerRow: Center(
        child: _button(
          child: Icon(Icons.check, size: 40.0),
          width: 80.0,
          onPressed: setMoveNext(),
        ),
      ),
    );
  }

  Widget _itemWidget(String topText, String bottomText, {Widget centerRow}) {
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
        _noteButton(),
        centerRow,
      ],
    );
  }

  Widget _noteButton() {
    if (_hasNotes()) {
      return Row(
        children: [
          Center(
            child: Container(
              width: _noteButtonWidth,
              height: 60.0,
              color: ThemeColors.black,
              child: OutlineButton(
                padding: EdgeInsets.all(0.0),
                child: Icon(Icons.list),
                onPressed: _getNotes,
                textColor: ThemeColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(
                        left: Radius.zero, right: Radius.circular(50.0))),
                disabledBorderColor: ThemeColors.primary,
                highlightedBorderColor: ThemeColors.primary,
                borderSide: BorderSide(color: ThemeColors.primary, width: 2.5),
                color: ThemeColors.primary,
              ),
            ),
          )
        ],
      );
    }

    return Row(children: <Widget>[]);
  }

  Future _getNotes() async {
    _notes = navigator.currentItem.getSortedNotes();
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: _noteDialogBuilder,
    );
  }

  Widget _noteDialogBuilder(BuildContext context) {
    return Dialog(
      child: OutlineButton(
        borderSide: BorderSide(color: ThemeColors.primary),
        textColor: ThemeColors.primary,
        onPressed: () => Navigator.of(context).pop(null),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  var note = _notes[index];
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          Strings.priorityToString(note.priority),
                          textScaleFactor: midScale,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            note.text,
                            textScaleFactor: smallScale,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(Strings.tapToClose),
            ),
          ],
        ),
      ),
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
          appBar: new AppBar(
            backgroundColor: ThemeColors.primary950,
            title: new Text(title),
            automaticallyImplyLeading: false,
            leading: navigator.canGoBack
                ? IconButton(
                    icon: BackButtonIcon(),
                    color: ThemeColors.primary,
                    onPressed: () => Navigator.of(context).maybePop(),
                  )
                : null,
            actions: [
              themeFlatButton(
                  child: Row(children: [
                    Icon(Icons.error_outline),
                    Text("/"),
                    Icon(Icons.menu),
                  ]),
                  onPressed: () async {
                    var newList = await showDialog<Checklist>(
                      context: context,
                      builder: (context) => ThemeDialog(
                            cancelButton: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: _button(
                                height: 50.0,
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(Strings.cancel),
                              ),
                            ),
                            child: DefaultTabController(
                              length: 2,
                              child: Scaffold(
                                appBar: PreferredSize(
                                  preferredSize: Size.fromHeight(80.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TabBar(
                                          tabs: <Widget>[
                                            Tab(text: Strings.emergencyLists),
                                            Tab(text: Strings.normalLists),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        child: Container(
                                          width: 50.0,
                                          height: 50.0,
                                          child: Icon(Icons.exit_to_app),
                                        ),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          _exitUseBook();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                body: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: TabBarView(
                                    children: <Widget>[
                                      _createListChooser(book.emergencyLists),
                                      _createListChooser(book.normalLists),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                    );

                    if (newList != null) {
                      setState(() => navigator.changeList(newList));
                    }
                  })
            ],
          ),
          body: AnimatedOpacity(
            duration: Duration(milliseconds: fadeDelay),
            opacity: opacity,
            child: _body(),
          ),
        ),
      );
    }
  }

  ListView _createListChooser(CommandList<Checklist> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: _createListChooserItemBuilder(list),
    );
  }

  Widget Function(BuildContext, int) _createListChooserItemBuilder(
      CommandList<Checklist> list) {
    return (context, index) {
      return Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: _button(
          height: 70.0,
          child: Text(
            list[index].name,
            textScaleFactor: smallScale,
          ),
          onPressed: () => Navigator.of(context).pop<Checklist>(list[index]),
        ),
      );
    };
  }
}
