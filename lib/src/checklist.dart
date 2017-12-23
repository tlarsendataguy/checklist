import 'dart:collection';

import 'package:checklist/src/item.dart';
import 'package:checklist/src/commandList.dart';

class Checklist extends CommandList<Item> {
  var _activeBranches = new ListQueue<BranchHistory>();
  var _priorItems = new ListQueue<BranchHistory>();
  int _currentIndex = 0;
  Item get currentItem => _getCurrentItem();
  Iterable<BranchHistory> get priorItems => _priorItems.toList();

  Checklist() : super();
  Checklist.fromSources(Iterable<Item> source) : super.fromIterable(source);

  Item nextItem({bool branch}) {
    var item = _getCurrentItem();

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
    while (_activeBranches.length > 0 && _currentIndex == list.length){
      var branch = _activeBranches.removeLast();
      _currentIndex = branch.index + 1;
      list = _getCurrentList();
    }

    return currentItem;
  }

  Item priorItem() {
    if (_currentIndex > 0 || _activeBranches.length > 0){
      _priorItems.removeLast();
      playHistory(_priorItems);
    }

    return currentItem;
  }

  void playHistory(Iterable<BranchHistory> history){
    if (history == _priorItems){
      history = new List.from(_priorItems);
    }

    _currentIndex = 0;
    _priorItems.clear();
    _activeBranches.clear();
    for (var item in history){
      nextItem(branch: item.branch);
    }
  }

  CommandList<Item> _getCurrentList(){
    CommandList<Item> list = this;

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
