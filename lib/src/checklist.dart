import 'package:checklist/src/item.dart';
import 'package:checklist/src/branch.dart';
import 'package:checklist/src/commandList.dart';
import 'package:checklist/src/command.dart';

class Checklist extends CommandList<Item> {
  int _currentIndex = 0;
  var _branches = new Map<int, Branch>();

  get currentIndex => _currentIndex;
  get branches => _branches.length;

  Checklist() : super();
  Checklist.fromSources(Iterable<Item> source, Map<int, Branch> branches)
      : super.fromIterable(source) {
    _branches = branches;
  }

  Branch branch(int at) {
    return _branches[at];
  }

  Item nextItem() {
    if (_currentIndex < length) _currentIndex++;
    if (_currentIndex == length) {
      return null;
    } else {
      return this[_currentIndex];
    }
  }

  Item priorItem() {
    if (_currentIndex > 0) _currentIndex--;
    return this[_currentIndex];
  }

  Item setCurrent(int newCurrent) {
    if (newCurrent < 0 || newCurrent > length) {
      throw new RangeError.range(newCurrent, 0, length);
    }

    _currentIndex = newCurrent;
    if (newCurrent == length) {
      return null;
    } else {
      return this[_currentIndex];
    }
  }

  Command createBranchAt(int index) {
    return new Command(new CreateBranch(this, index));
  }

  Command removeBranchAt(int index) {
    return new Command(new RemoveBranch(this, index));
  }
}

class CreateBranch extends CommandAction {
  final Checklist list;
  final int index;
  Branch _branch;
  String get key => "Checklist.CreateBranch";

  CreateBranch(this.list, this.index) {
    if (index < 0 || index >= list.length) {
      throw new RangeError.range(index, 0, list.length - 1);
    }
    if (list.branch(index) != null)
      throw new UnsupportedError(
          "Only one branch can be created at each position.  The index $index already has a branch.");

    _branch = new Branch(
      lenTrue: 0,
      lenFalse: 0,
    );
  }

  action() {
    list._branches.putIfAbsent(index, () => _branch);
  }

  undoAction() {
    list._branches.remove(index);
  }
}

class RemoveBranch extends CommandAction {
  final Checklist list;
  final int index;
  Branch _branch;
  String get key => "Checklist.RemoveBranch";

  RemoveBranch(this.list, this.index) {
    if (index < 0 || index >= list.length)
      throw new RangeError.range(index, 0, list.length - 1);

    if (list.branch(index) == null)
      throw new UnsupportedError(
          "There was no branch at position $index to delete");

    _branch = list.branch(index);
  }

  action() {
    list._branches.remove(index);
  }

  undoAction() {
    list._branches.putIfAbsent(index, () => _branch);
  }
}
