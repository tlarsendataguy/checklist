import "package:ps_command/command.dart";
import 'package:ps_commandlist/commandlist.dart';
import 'package:checklist/src/note.dart';

class Item {
  String _toCheck;
  String _action;
  var trueBranch = new CommandList<Item>(tag: "TrueBranch");
  var falseBranch = new CommandList<Item>(tag: "FalseBranch");
  var notes = new CommandList<Note>(tag: "Notes");

  get toCheck => _toCheck;
  get action => _action;
  get isBranch => trueBranch.length + falseBranch.length > 0;

  Item(String toCheck, {String action}) {
    if (toCheck == null) throw new ArgumentError.notNull("toCheck");
    _toCheck = toCheck;
    _action = action != null ? action : "";
  }

  Command setAction(String newAction) {
    return new Command(new ChangeAction(this, newAction));
  }

  Command setToCheck(String newToCheck) {
    return new Command(new ChangeToCheck(this, newToCheck));
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
