import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:checklist/ui/templates.dart';

typedef void AdditionalInitsCallback(ParsedItems result);

class EditorPage extends StatefulWidget {
  EditorPage(this.path, this.onThemeChanged);

  final String path;
  final ThemeChangeCallback onThemeChanged;

  EditorPageState createState() => new EditorPageState();
}

class EditorPageState extends State<EditorPage> {
  EditorPageState();

  bool isLoading = true;

  initEditorState(AdditionalInitsCallback additionalInits) {
    ParsePath.parse(widget.path).then((ParsedItems result) {
      setState(() {
        isLoading = false;
        additionalInits(result);
      });
    });
  }

  Widget buildPage({BuildContext context, String title, Widget body}) {
    return new Scaffold(
      appBar: themeAppBar(
        title: title,
        onThemeChanged: (makeRed) =>setState(()=>widget.onThemeChanged(makeRed)),
      ),
      body: _getBody(context, body),
    );
  }

  Widget _getBody(BuildContext context, Widget body) {
    if (isLoading)
      return new Center(
        child: new CupertinoActivityIndicator(),
      );
    else
      return new Padding(
        padding: pagePadding,
        child: body,
      );
  }

  build(BuildContext context) {
    buildPage(context: context, title: "", body: null);
  }
}
