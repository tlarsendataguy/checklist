import 'dart:collection';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/item.dart';
import 'package:commandlist/commandlist.dart';

class Navigator {
  Navigator(this.book){
    currentList = book.normalLists[0];
  }

  Book book;
  Checklist currentList;
  Checklist priorList;
  ListQueue<BranchHistory> priorHistory;
  var _activeBranches = new ListQueue<BranchHistory>();
  var _priorItems = new ListQueue<BranchHistory>();
  int _currentIndex = 0;
  Item get currentItem => _getCurrentItem();
  List<BranchHistory> readPriorItems() => _priorItems.toList();

  navigateTo(Checklist list) {
    priorList = currentList;
    priorHistory = _priorItems;
    currentList = list;
  }


  Item nextItem({bool branch}) {
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
    if (item != null && item.isBranch) {
      if (branch == null)
        throw new UnsupportedError(
            "The branch parameter must be specified if the current item is a branch");

      _activeBranches.addLast(new BranchHistory(_currentIndex, branch));
      _priorItems.addLast(new BranchHistory(_currentIndex, branch));
      _currentIndex = 0;
    } else {
      _priorItems.add(new BranchHistory(_currentIndex, branch));
      _currentIndex++;
    }

    //Get the current list and truncate current index to the list length if it exceeds it
    var list = _getCurrentList();
    if (_currentIndex > list.length) _currentIndex = list.length;

    //If we are at the end of a branch, pop the history until we find an unfinished branch
    //or we reach the base checklist
    while (_activeBranches.length > 0 && _currentIndex == list.length) {
      var branch = _activeBranches.removeLast();
      _currentIndex = branch.index + 1;
      list = _getCurrentList();
    }

    return currentItem;
  }

  Item priorItem() {
    if (_currentIndex > 0 || _activeBranches.length > 0) {
      _priorItems.removeLast();
      playHistory(_priorItems);
    }

    return currentItem;
  }

  void playHistory(Iterable<BranchHistory> history) {
    var reversionPriorItems = new List.from(_priorItems);
    var reversionCurrentIndex = _currentIndex;
    var reversionActiveBranches = new List.from(_activeBranches);

    if (history == _priorItems) {
      history = new List.from(_priorItems);
    }

    try {
      _currentIndex = 0;
      _priorItems.clear();
      _activeBranches.clear();
      for (var item in history) {
        nextItem(branch: item.branch);
      }
    } catch (ex) {
      _priorItems = new ListQueue.from(reversionPriorItems);
      _currentIndex = reversionCurrentIndex;
      _activeBranches = new ListQueue.from(reversionActiveBranches);
      throw new ArgumentError("The provided history was not valid");
    }
  }

  CommandList<Item> _getCurrentList() {
    CommandList<Item> list = currentList;

    for (var branch in _activeBranches) {
      if (branch.branch)
        list = list[branch.index].trueBranch;
      else
        list = list[branch.index].falseBranch;
    }

    return list;
  }

  Item _getCurrentItem() {
    var list = _getCurrentList();
    if (list.length == _currentIndex)
      return null;
    else
      return list[_currentIndex];
  }
}


class BranchHistory {
  final int index;
  final bool branch;

  bool get isBranch => branch != null;

  BranchHistory(this.index, this.branch);
}
