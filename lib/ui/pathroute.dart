import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class PathRoute extends MaterialPageRoute<int> {
  PathRoute({@required WidgetBuilder builder,RouteSettings settings,this.level, this.willHandlePopInternally = false})
   : super(builder: builder, settings: settings,maintainState: false);

  final int level;

  int get currentResult => level;
  bool willHandlePopInternally = false;
}