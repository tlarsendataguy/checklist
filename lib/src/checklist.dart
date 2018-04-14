import 'package:command/command.dart';
import 'package:commandlist/commandlist.dart';
import 'package:checklist/src/item.dart';
import 'package:checklist/src/randomid.dart';
import 'package:meta/meta.dart';

class Checklist extends CommandList<Item> {
  Checklist({
    @required String name,
    Iterable<Item> source,
    Checklist nextPrimary,
    Iterable<Checklist> nextAlternatives,
    String id,
  })
      : super(source: source, tag: "Checklist") {
    assert(name != null);
    _name = name;
    _id = id ?? RandomId.generate();
    _nextPrimary = nextPrimary;
    _nextAlternatives = new CommandList<Checklist>(
        source: nextAlternatives, tag: "NextAlternatives");
  }

  String _name;
  String _id;
  Checklist _nextPrimary;
  CommandList<Checklist> _nextAlternatives;

  CommandList<Checklist> get nextAlternatives => _nextAlternatives;
  String get name => _name;
  Checklist get nextPrimary => _nextPrimary;
  String get id => _id;

  Command rename(String newName) {
    return new Command(new RenameList(this, newName))..execute();
  }

  Command setNextPrimary(Checklist next) {
    return new Command(new SetNextPrimary(this, next))..execute();
  }
}

class RenameList extends CommandAction {
  final String newName;
  final String oldName;
  final Checklist list;

  String get key => "Checklist.Rename";

  RenameList(this.list, this.newName) : oldName = list.name;

  action() {
    list._name = newName;
  }

  undoAction() {
    list._name = oldName;
  }
}

class SetNextPrimary extends CommandAction {
  final Checklist list;
  final Checklist newPrimary;
  final Checklist oldPrimary;

  String get key => "Checklist.SetNextPrimary";

  SetNextPrimary(this.list, this.newPrimary) : oldPrimary = list.nextPrimary;

  action() {
    list._nextPrimary = newPrimary;
  }

  undoAction() {
    list._nextPrimary = oldPrimary;
  }
}
