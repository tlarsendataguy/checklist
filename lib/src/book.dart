import 'package:checklist/src/randomid.dart';
import 'package:checklist/src/checklist.dart';
import 'package:commandlist/commandlist.dart';
import 'package:command/command.dart';
import 'package:meta/meta.dart';

class Book {
  static const String _normalTag = "NormalLists";
  static const String _emergencyTag = "EmergencyLists";
  String _name;
  String _id;
  CommandList<Checklist> _normalLists;
  CommandList<Checklist> _emergencyLists;

  String get name => _name;
  String get id => _id;
  CommandList<Checklist> get normalLists => _normalLists;
  CommandList<Checklist> get emergencyLists => _emergencyLists;

  Book({
      @required String name,
      String id,
      Iterable<Checklist> normalLists,
      Iterable<Checklist> emergencyLists,
  }) : assert(name != null) {
    _name = name;
    _id = id ?? RandomId.generate();
    _normalLists = new CommandList(
      source: normalLists,
      tag: _normalTag,
      onRemove: _checklistRemoved,
    );
    _emergencyLists = new CommandList(
      source: emergencyLists,
      tag: _emergencyTag,
      onRemove: _checklistRemoved
    );
  }

  Command _checklistRemoved(Checklist list){
    return new Command(new UpdateNexts(this,list));
  }

  Command changeName(String newName){
    return new Command(new ChangeName(this,newName))..execute();
  }

}

class ChangeName extends CommandAction{
  final Book container;
  final String newName;
  final String oldName;
  String get key => "Book.ChangeName";

  ChangeName(this.container,this.newName) : oldName = container.name;

  action(){
    container._name = newName;
  }
  undoAction(){
    container._name = oldName;
  }
}

class UpdateNexts extends CommandAction {
  UpdateNexts(this.book,this.removed);

  final Book book;
  final Checklist removed;
  String get key => "Book.UpdateAlternatives";
  var _wasPrimaryNext = new List<Checklist>();
  var _wasAlternativeNext = new List<_AlternativeMap>();

  action() {
    _wasPrimaryNext.clear();
    _wasAlternativeNext.clear();

    for (var collection in [book.normalLists,book.emergencyLists]) {
      for (var list in collection) {
        if (list.nextPrimary == removed) {
          _wasPrimaryNext.add(list);
          list.setNextPrimary(null);
        }

        int index = 0;
        for (var alternative in list.nextAlternatives) {
          if (alternative == removed) {
            _wasAlternativeNext.add(new _AlternativeMap(list, index));
            list.nextAlternatives.remove(removed);
          }

          index++;
        }
      }
    }
  }

  undoAction() {
    for (var list in _wasPrimaryNext) {
      list.setNextPrimary(removed);
    }

    int lastIndex = _wasAlternativeNext.length - 1;
    for (int index = lastIndex; index >= 0; index--) {
      var addAgain = _wasAlternativeNext[index].list.nextAlternatives;
      addAgain.insert(removed,index: index);
    }
  }
}

class _AlternativeMap{
  _AlternativeMap(this.list,this.index);

  final Checklist list;
  final int index;
}
