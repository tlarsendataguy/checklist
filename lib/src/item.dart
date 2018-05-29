import "package:command/command.dart";
import 'package:commandlist/commandlist.dart';
import 'package:checklist/src/note.dart';

class Item {
  Item({String toCheck, String action,Iterable<Item> trueBranch,Iterable<Item> falseBranch,Iterable<Note> notes}) : assert(toCheck != null) {
    _toCheck = toCheck;
    _action = action ?? "";
    _trueBranch = new CommandList<Item>(source: trueBranch,tag: "TrueBranch");
    _falseBranch = new CommandList<Item>(source: falseBranch,tag: "FalseBranch");
    _notes = new CommandList<Note>(source: notes,tag: "Notes");
  }

  String _toCheck;
  String _action;
  CommandList<Item> _trueBranch;
  CommandList<Item> _falseBranch;
  CommandList<Note> _notes;

  String get toCheck => _toCheck;
  String get action => _action;
  bool get isBranch => trueBranch.length + falseBranch.length > 0;
  CommandList<Item> get trueBranch => _trueBranch;
  CommandList<Item> get falseBranch => _falseBranch;
  CommandList<Note> get notes => _notes;

  List<Note> getSortedNotes(){
    return _notes.toList()..sort();
  }

  Command setAction(String newAction) {
    return new Command(new ChangeAction(this, newAction))..execute();
  }

  Command setToCheck(String newToCheck) {
    return new Command(new ChangeToCheck(this, newToCheck))..execute();
  }
}

class ChangeAction extends CommandAction {
  final Item item;
  String newAction;
  String get key => "Item.ChangeAction";

  ChangeAction(this.item, this.newAction);

  void action() {
    var oldAction = item.action;
    item._action = newAction;
    newAction = oldAction;
  }

  void undoAction() {
    action();
  }
}

class ChangeToCheck extends CommandAction {
  final Item item;
  String newToCheck;
  String get key => "Item.ChangeToCheck";

  ChangeToCheck(this.item, this.newToCheck);

  void action() {
    var oldToCheck = item.toCheck;
    item._toCheck = newToCheck;
    newToCheck = oldToCheck;
  }

  void undoAction() {
    action();
  }
}
