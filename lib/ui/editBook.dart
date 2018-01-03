import 'package:flutter/material.dart';

class EditBook extends StatefulWidget {
  final String id;
  EditBook(this.id);

  _EditBookState createState() => new _EditBookState();
}

class _EditBookState extends State<EditBook> {
  _EditBookState();

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Edit book"),
      ),
      body: new Padding(
        padding: new EdgeInsets.all(12.0),
        child: new Text("Hello world!"),
      ),
    );
  }
}
