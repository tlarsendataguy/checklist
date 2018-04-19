import 'dart:convert';

import 'package:checklist/src/diskwriter.dart';
import 'package:checklist/src/navigator.dart';


class NavigatorIo {
  NavigatorIo(this.navigator,this.writer): assert(navigator != null && writer != null);

  Navigator navigator;
  DiskWriter writer;

  String serialize(){
    var jsonContaner = {
      "currentList": navigator.currentList?.id,
      "priorList": navigator.priorList?.id,
      "currentHistory": _historyToMap(navigator.readCurrentHistory()),
      "priorHistory": _historyToMap(navigator.readPriorHistory()),
    };

    return json.encode(jsonContaner);
  }

  List<Map<String,Object>> _historyToMap(List<NavigationHistory> history) {
    var mappedHistory = new List<Map<String,Object>>();
    for (var step in history) {
      mappedHistory.add({"index": step.index, "branch": step.branch});
    }
    
    return mappedHistory;
  }
}