import 'package:flutter/material.dart';

import 'package:checklist/ui/templates.dart';

class ListViewPageFrame extends StatelessWidget {
  ListViewPageFrame({this.listContent,this.bottomContent});

  final Widget listContent;
  final Widget bottomContent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: defaultT,
      child: Column(
        children: <Widget>[
          Expanded(
            child: listContent,
          ),
          new Row(
            children: <Widget>[
              Expanded(
                child: new Padding(
                  padding: defaultLRB,
                  child: bottomContent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}