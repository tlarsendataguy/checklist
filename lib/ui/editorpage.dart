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

  void afterParseInit();

  initState() {
    super.initState();

    ParsePath.parse(widget.path).then((ParsedItems result) {
      setState(() {
        parseResult = result;
        book = result.book;
        isLoading = false;
        if (afterParseInit != null) afterParseInit();
      });
    });
  }

  Widget buildEditorPage(Widget buildBody()) {
    return new Scaffold(
      appBar: appBar,
      body: isLoading
          ? Center(
              child: CupertinoActivityIndicator(),
            )
          : buildBody(),
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
