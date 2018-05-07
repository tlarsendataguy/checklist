import 'dart:collection';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/item.dart';
import 'package:commandlist/commandlist.dart';

class Navigator {
  Navigator(this.book) {
    if (book.normalLists.length > 0) currentList = book.normalLists[0];
  }

  Book book;
  Checklist currentList;
  Checklist priorList;

  var _currentHistory = new ListQueue<NavigationHistory>();
  var _currentBranches = new ListQueue<NavigationHistory>();
  var _priorHistory = new ListQueue<NavigationHistory>();
  int _currentIndex = 0;

  Item get currentItem => _getCurrentItem();
  bool get canMoveNext =>
      currentList != null && (_currentIndex < currentList.length || _currentBranches.length > 0);
  bool get canGoBack =>
      _currentIndex > 0 || _currentBranches.length > 0 || priorList != null;

  List<NavigationHistory> readPriorHistory() => _priorHistory.toList();
  List<NavigationHistory> readCurrentHistory() => _currentHistory.toList();

  changeList(Checklist list) {
    priorList = currentList;
    _priorHistory = _currentHistory;
    currentList = list;
    _currentHistory = new ListQueue<NavigationHistory>();
    _currentBranches = new ListQueue<NavigationHistory>();
    _currentIndex = 0;
  }

  Item moveNext({bool branch}) {
    var item = _getCurrentItem();
    if (item != null && !item.isBranch && branch != null)
      throw new UnsupportedError(
          "The branch parameter cannot be specified if the current item is not a branch");
    if (item == null)
      throw new UnsupportedError(
          "Cannot move to the next item after the end of the list");

    //Make sure the 'branch' parameter was provided if the current item is a branch
    //If the current item is a branch, current item becomes the first item of the specified branch
    //If the current item is not a branch, the current item is incremented
    var history = new NavigationHistory(_currentIndex, branch);
    if (item != null && item.isBranch) {
      if (branch == null)
        throw new UnsupportedError(
            "The branch parameter must be specified if the current item is a branch");

      _currentBranches.addLast(history);
      _currentIndex = 0;
    } else {
      _currentIndex++;
    }
    _currentHistory.addLast(history);

    //Get the current list and truncate current index to the list length if it exceeds it
    var list = _getCurrentContext();
    if (_currentIndex > list.length) _currentIndex = list.length;

    //If we are at the end of a branch, pop the history until we find an unfinished branch
    //or we reach the base checklist
    while (_currentBranches.length > 0 && _currentIndex == list.length) {
      var branch = _currentBranches.removeLast();
      _currentIndex = branch.index + 1;
      list = _getCurrentContext();
    }

    return currentItem;
  }

  Item goBack() {
    if (_currentHistory.length > 0) {
      _currentHistory.removeLast();
      playHistory(_currentHistory.toList());
    } else if (priorList != null) {
      currentList = priorList;
      playHistory(_priorHistory.toList());
      _priorHistory.clear();
      priorList = null;
    }

    return currentItem;
  }

  void playHistory(Iterable<NavigationHistory> history) {
    var revertCurrentIndex = _currentIndex;
    var revertCurrentHistory = new List.from(_currentHistory);
    var revertCurrentDecisions = new List.from(_currentBranches);

    try {
      _currentIndex = 0;
      _currentHistory.clear();
      _currentBranches.clear();

      for (var item in history) {
        moveNext(branch: item.branch);
      }
    } catch (ex) {
      _currentIndex = revertCurrentIndex;
      _currentHistory = new ListQueue.from(revertCurrentHistory);
      _currentBranches = new ListQueue.from(revertCurrentDecisions);
      throw new ArgumentError("The provided history was not valid");
    }
  }

  CommandList<Item> _getCurrentContext() {
    CommandList<Item> context = currentList;

    for (var branch in _currentBranches) {
      if (branch.branch != null) {
        if (branch.branch)
          context = context[branch.index].trueBranch;
        else
          context = context[branch.index].falseBranch;
      }
    }

    return context;
  }

  Item _getCurrentItem() {
    var list = _getCurrentContext();
    if (list == null)
      return null;

    if (list.length == _currentIndex)
      return null;

    return list[_currentIndex];
  }
}

class NavigationHistory {
  final int index;
  final bool branch;

  bool get isBranch => branch != null;

  NavigationHistory(this.index, this.branch);
}
