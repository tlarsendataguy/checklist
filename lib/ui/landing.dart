import 'package:checklist/ui/strings.dart';
import 'package:flutter/material.dart';
import 'package:checklist/src/bookio.dart';
import 'package:checklist/ui/templates.dart';

class Landing extends StatefulWidget {
  Landing(this.onThemeChanged,{Key key}) : super(key: key);

  final ThemeChangeCallback onThemeChanged;

  _LandingState createState() => new _LandingState();
}

class _LandingState extends State<Landing> {
  var books = new List<Widget>();
  BookIo io;

  _LandingState();

  initState() {
    super.initState();

    io = new BookIo()
      ..initializeFileList().then((_) {
        setState(() {
          for (var id in io.files.keys) {
            books.add(
              new Container(
                height: 48.0,
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                      child: new Padding(
                        child: overflowText(io.files[id]),
                        padding: const EdgeInsets.only(left: defaultPad),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.fromLTRB(
                          defaultPad, 0.0, defaultPad, 0.0),
                      child: new InkWell(
                        child: new Icon(Icons.edit),
                        onTap: () {
                          Navigator.of(context).pushNamed("/$id");
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        });
      });
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: themeAppBar(
        title: Strings.appTitle,
        onThemeChanged: (makeRed) {
          setState(()=>widget.onThemeChanged(makeRed));
        },
      ),
      body: new Padding(
          padding: const EdgeInsets.only(top: listTopPad),
          child: _buildListview(context)),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/newBook");
        },
        child: new Icon(Icons.add),
      ),
    );
  }

  Widget _buildListview(BuildContext context) {
    if (books.length == 0) {
      return new ListView();
    } else {
      return new ListView.builder(
        itemBuilder: (context, index) {
          return books[index];
        },
        itemCount: books.length,
      );
    }
  }
}
