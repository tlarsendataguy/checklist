import 'package:flutter/material.dart';

const double defaultPad = 16.0;
const double listTopPad = 8.0;
var pagePadding = const EdgeInsets.fromLTRB(defaultPad, 0.0, defaultPad, 0.0);
var defaultPadding = const EdgeInsets.fromLTRB(0.0, defaultPad, 0.0, 0.0);

Widget editorElementPadding({Widget child}){
  return new Padding(
    padding: defaultPadding,
    child: child,
  );
}

Widget overflowText(String text){
  return new Text(
    text,
    softWrap: false,
    overflow: TextOverflow.ellipsis,
  );
}
