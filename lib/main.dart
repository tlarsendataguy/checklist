import 'package:flutter/material.dart';
import 'package:checklist/ui/landing.dart';
import 'package:checklist/ui/newbook.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Checklist App',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Landing(),
      routes: {
        "/newBook": (BuildContext context) => new NewBook(),
      },
    );
  }
}
