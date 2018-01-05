import 'package:flutter/material.dart';
import 'package:checklist/src/bookio.dart';

class Landing extends StatefulWidget {
  Landing({Key key}) : super(key: key);

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
              new Row(
                children: <Widget>[
                  new Expanded(
                  child: new Text(io.files[id]),
            ),
                    new IconButton(
                        icon: new Icon(Icons.edit),
                        onPressed: (){
                          Navigator.of(context).pushNamed("/$id");
                        },
                    ),
                ],
              ),
            );
          }
        });
      });
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Checklist App"),
      ),
      body: _buildListview(context),
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
