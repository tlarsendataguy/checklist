import 'package:flutter/material.dart';

class Landing extends StatefulWidget {
  Landing({Key key}) : super(key: key);

  _LandingState createState() => new _LandingState();
}

class _LandingState extends State<Landing> {
  _LandingState();

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Checklist App"),
      ),
      body: new ListView(),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed("/newBook");
        },
        child: new Icon(Icons.add),
      ),
    );
  }
}
