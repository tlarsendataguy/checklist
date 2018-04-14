import 'package:checklist/src/book.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


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

  @override
  void initState() {
    super.initState();

    ParsePath.parse(widget.path).then<ParsedItems>(
        (items) {
          if (mounted) {
            setState((){
              if (items.result == ParseResult.UseBook)
                book = items.book;
              isLoading = false;
            });
          }
        },
      onError: (error) {
          if (mounted) {
            setState((){
              isLoading = false;
              errorLoading = true;
            });
          }
      }
    );
  }

  Widget _body(){
    return new Scaffold(
      appBar: new AppBar(title: new Text(book.name)),
      body: new Text(book.normalLists[0].currentItem.toCheck),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return new CupertinoActivityIndicator();
    else if (errorLoading)
      return new Text("Error");
    else
      return _body();
  }
}