import 'dart:convert';

import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/diskwriter.dart';
import 'package:checklist/src/exceptions.dart';
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

  void deserialize(String serializedData){
    try{
      Map<String,Object> map = json.decode(serializedData);
      String priorId = map["priorList"];
      String currentId = map["currentList"];
      var priorHistory = _extractHistory(map['priorHistory']);
      var currentHistory = _extractHistory(map['currentHistory']);

      bool foundCurrent = false, foundPrior = false;
      Checklist currentList;
      for (var collection in [navigator.book.normalLists, navigator.book.emergencyLists]) {
        for (var list in collection){
          if (list.id == priorId) {
            navigator.currentList = list;
            navigator.playHistory(priorHistory);
            foundPrior = true;
          }
          if (list.id == currentId) {
            currentList = list;
            foundCurrent = true;
          }
          if (foundCurrent && foundPrior) break;
        }
      }

      if (priorId != null) {
        navigator.changeList(currentList);
      } else {
        navigator.currentList = currentList;
      }
      navigator.playHistory(currentHistory);

    } catch (_, stacktrace){
      throw new MalformedStringException(
        "The string is not a valid NavigatorIo oject",
        stacktrace
      );
    }
  }

  List<NavigationHistory> _extractHistory(List<dynamic> jsonHistory) {
    var history = new List<NavigationHistory>();

    for (Map<String,Object> step in jsonHistory) {
      history.add(new NavigationHistory(step['index'], step['branch']));
    }

    return history;
  }

  List<Map<String,Object>> _historyToMap(List<NavigationHistory> history) {
    var mappedHistory = new List<Map<String,Object>>();
    for (var step in history) {
      mappedHistory.add({"index": step.index, "branch": step.branch});
    }
    
    return mappedHistory;
  }
}