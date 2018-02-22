import 'package:checklist/src/book.dart';
import 'package:checklist/src/bookio.dart';
import 'package:commandlist/commandlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:checklist/ui/templates.dart';

typedef void AdditionalInitsCallback(ParsedItems result);

abstract class EditorPage extends StatefulWidget {
  EditorPage(this.path, this.onThemeChanged, this.padding);

  final String path;
  final ThemeChangeCallback onThemeChanged;
  final EdgeInsetsGeometry padding;
}

abstract class EditorPageState extends State<EditorPage> {
  EditorPageState();

  bool isLoading = true;
  BookIo io = new BookIo();
  Book book;

  initEditorState(AdditionalInitsCallback additionalInits) {
    ParsePath.parse(widget.path).then((ParsedItems result) {
      setState(() {
        book = result.book;
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

  OnMove buildOnMove(CommandList list){
    return (int oldIndex, int newIndex) async {
      var command = list.moveItem(oldIndex, newIndex);
      setState((){});
      if (!await io.persistBook(book)) {
        setState(()=> command.undo());
      }
    };
  }
}
