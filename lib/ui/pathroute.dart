import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class PathRoute extends MaterialPageRoute<int> {
  PathRoute({@required WidgetBuilder builder,RouteSettings settings,this.level})
   : super(builder: builder, settings: settings,maintainState: false);

  final int level;

  int get currentResult => level;
}