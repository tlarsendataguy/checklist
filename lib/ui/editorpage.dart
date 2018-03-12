import 'dart:async';
import 'package:flutter/cupertino.dart';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/bookio.dart';
import 'package:checklist/src/mobilediskwriter.dart';
import 'package:checklist/ui/navigationpage.dart';
import 'package:command/command.dart';
import 'package:commandlist/commandlist.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:checklist/ui/templates.dart';
import 'package:flutter/material.dart';

typedef void AdditionalInitsCallback(ParsedItems result);
typedef void OnMove(int oldIndex, int newIndex);

abstract class EditorPage extends NavigationPage {
  EditorPage({String title, String path, ThemeChangeCallback onThemeChanged})
      : super(title: title, path: path, onThemeChanged: onThemeChanged);
}

abstract class EditorPageState extends NavigationPageState {
  bool isLoading = true;
  BookIo io = new BookIo(writer: new MobileDiskWriter());
  Book book;
  ParsedItems parseResult;
  var navigationTree = new List<Widget>();

  void afterParseInit();

  initState() {
    super.initState();
    var elements = widget.path.split('/');
    IconData icon;

    navigationTree.add(
      Positioned(
        left: 0.0,
        right: 0.0,
        top: 0.0,
        bottom: 0.0,
        child: Hero(
          tag: "NavBarBackground",
          child: Container(
            color: ThemeColors.black,
          ),
        ),
      ),
    );

    for (int i = 0; i < elements.length; i++) {
      switch (i) {
        case 0:
          icon = Icons.home;
          break;
        case 1:
          icon = Icons.book;
          break;
        case 2:
          icon = Icons.add_box;
          break;
        case 3:
          icon = Icons.pages;
          break;
        case 4:
          icon = Icons.list;
          break;
        case 5:
          icon = Icons.check;
          break;
        case 6:
          icon = Icons.note_add;
          break;
        case 7:
          icon = Icons.note;
          break;
        default:
          break;
      }

      navigationTree.add(
        Positioned(
          top: i * 50.0,
          child: Hero(
            tag: i,
            child: Material(
              child: SizedBox(
                height: 50.0,
                width: 50.0,
                child: InkWell(
                  onTap: goBackTo(i),
                  child: Icon(icon),
                ),
              ),
            ),
          ),
        ),
      );
    }

    navigationTree.add(
      Positioned(
        top: (elements.length * 50.0),
        left: 50.0,
        child: Hero(
          tag: elements.length,
          child: SizedBox(
            height: 50.0,
            width: 50.0,
          ),
        ),
      ),
    );

    navigationTree.add(
      Positioned(
        top: (elements.length - 1) * 50.0,
        child: Hero(
          tag: "CurrentNavigationPosition",
          child: Container(
            width: 50.0,
            height: 50.0,
            color: ThemeColors.primaryTransparent,
          ),
        ),
      ),
    );

    ParsePath.parse(widget.path).then((ParsedItems result) {
      setState(() {
        parseResult = result;
        book = result.book;
        isLoading = false;
        if (afterParseInit != null) afterParseInit();
      });
    });
  }

  Function goBackTo(int level) {
    return () {
      Navigator.of(context).popUntil((route) {
        return route.currentResult == level;
      });
    };
  }

  Widget buildEditorPage(Widget buildBody()) {
    return new Scaffold(
      appBar: appBar,
      body: Row(
        children: <Widget>[
          Expanded(
            child: isLoading
                ? Center(
                    child: CupertinoActivityIndicator(),
                  )
                : buildBody(),
          ),
          Container(
            width: 50.0,
            child: Stack(
              children: navigationTree,
            ),
          ),
        ],
      ),
    );
  }

  OnMove buildOnMove(CommandList list) {
    return (int oldIndex, int newIndex) async {
      var command = list.moveItem(oldIndex, newIndex);
      setState(() {});
      await persistBookOrUndo(command);
    };
  }

  Future persistBookOrUndo(Command command) async {
    if (!await io.persistBook(book)) {
      setState(() => command.undo());
    }
  }
}
