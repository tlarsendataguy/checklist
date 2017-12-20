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

  Command insert(Item item,{int index}){
    return new Command(new ChecklistInsertItem(this,item,index));
  }

  Command remove(Item item){
    return new Command(new ChecklistRemoveItem(this,item));
  }

  Command createBranchAt(int index) {
    return new Command(new CreateBranch(this, index));
  }

  Command removeBranchAt(int index) {
    return new Command(new RemoveBranch(this, index));
  }

  Command addTrueBranch(int branchAt,Item item){
    return new Command(new AddTrueBranch(this,branchAt,item));
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

class AddTrueBranch extends CommandAction{
  final Checklist list;
  final int branchAt;
  final Item item;
  String get key => 'Checklist.AddTrueBranch';

  AddTrueBranch(this.list,this.branchAt,this.item);

  action(){
    var branch = list.branch(branchAt);
    var insertAt = branch.lenTrue + branchAt + 1;
    list.insert(item,index: insertAt);
    branch.incrementTrue();
  }

  undoAction(){
    var branch = list.branch(branchAt);
    list.remove(item);
    branch.decrementTrue();
  }
}

class ChecklistInsertItem extends InsertItem<Item>{
  final Checklist list;
  final Item item;
  final int index;
  String get key => "Checklist.InsertItem";
  IncrementBranchesAfterInsert _branchCommand;

  ChecklistInsertItem(this.list,this.item,this.index) : super(list,item,index){
    _branchCommand = new IncrementBranchesAfterInsert(list, index);
  }

  action(){
    super.action();
    _branchCommand.action();
  }

  undoAction(){
    super.undoAction();
    _branchCommand.undoAction();
  }
}

class ChecklistRemoveItem extends RemoveItem<Item>{
  final Checklist list;
  final Item item;
  String get key => "Checklist.RemoveItem";
  DecrementBranchesAfterDelete _branchCommand;

  ChecklistRemoveItem(this.list,this.item) : super(list,item);

  action(){
    var index = list.indexOf(item);
    _branchCommand = new DecrementBranchesAfterDelete(list, index);
    super.action();
    _branchCommand.action();
  }

  undoAction(){
    super.undoAction();
    _branchCommand.undoAction();
  }
}

class IncrementBranchesAfterInsert extends CommandAction{
  final Checklist list;
  final int index;
  String get key => "Checklist.IncrementBranchesAfterInsert";

  IncrementBranchesAfterInsert(this.list,this.index);

  action(){
    var newBranches = new Map<int,Branch>();
    int newIndex;

    for (var key in list._branches.keys){
      newIndex = key;
      if (key >= index) newIndex++;
      newBranches.putIfAbsent(newIndex, () => list.branch(key));
    }
    list._branches = newBranches;
  }

  undoAction(){
    var newBranches = new Map<int,Branch>();
    int newIndex;

    for (var key in list._branches.keys){
      newIndex = key;
      if (key > index) newIndex--;
      newBranches.putIfAbsent(newIndex, () => list.branch(key));
    }
    list._branches = newBranches;
  }
}

class DecrementBranchesAfterDelete extends CommandAction{
  final Checklist list;
  final int index;
  String get key => "Checklist.DecrementBranchesAfterDelete";

  DecrementBranchesAfterDelete(this.list,this.index);

  action(){
    var newBranches = new Map<int,Branch>();
    int newIndex;

    for (var key in list._branches.keys){
      newIndex = key;
      if (key > index) newIndex--;
      newBranches.putIfAbsent(newIndex, () => list.branch(key));
    }
    list._branches = newBranches;
  }

  undoAction(){
      var newBranches = new Map<int,Branch>();
      int newIndex;

      for (var key in list._branches.keys){
        newIndex = key;
        if (key >= index) newIndex++;
        newBranches.putIfAbsent(newIndex, () => list.branch(key));
      }
      list._branches = newBranches;
    }
}
