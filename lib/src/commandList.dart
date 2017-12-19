import 'dart:collection';
import 'package:checklist/src/command.dart';

abstract class CommandList<E> extends IterableBase<E> {
  List<E> _items = new List<E>();

  CommandList();
  CommandList.fromIterable(Iterable<E> source) {
    _items.addAll(source);
  }

  E operator [](int i) => _items[i];

  Iterator<E> get iterator => new CommandListIterator(_items);

  Command insert(E item, {int index}) {
    return new Command(new InsertItem(this, item, index));
  }

  Command remove(E item) {
    return new Command(new RemoveItem(this, item));
  }

  Command moveItem(int oldIndex, int newIndex) {
    return new Command(new MoveItem(this, oldIndex, newIndex));
  }
}

class CommandListIterator<E> extends Iterator<E> {
  List<E> _list;
  int _index = 0;
  E _current;

  CommandListIterator(List<E> list) {
    _list = list;
  }

  bool moveNext() {
    if (_index <= _list.length - 1) {
      _current = _list[_index];
      _index++;
      return true;
    } else {
      _current = null;
      return false;
    }
  }

  E get current => _current;
}

class InsertItem<E> implements CommandAction {
  final CommandList list;
  final E item;
  final int index;
  String get key => "CommandList.Insert";

  InsertItem(this.list, this.item, this.index);

  action() {
    if (index == null) {
      list._items.add(item);
    } else {
      list._items.insert(index, item);
    }
  }

  undoAction() {
    list._items.remove(item);
  }
}

class RemoveItem<E> implements CommandAction {
  final CommandList list;
  final E item;
  int _index;
  String get key => "CommandList.Remove";

  RemoveItem(this.list, this.item);

  action() {
    _index = getIndex();
    list._items.remove(item);
  }

  undoAction() {
    if (_index >= 0) {
      if (_index < list.length) {
        list._items.insert(_index, item);
      } else {
        list._items.add(item);
      }
    }
  }

  int getIndex() {
    int i = 0;
    for (var currentItem in list._items) {
      if (currentItem == item) {
        return i;
      }
      i++;
    }
    return -1;
  }
}

class MoveItem implements CommandAction {
  final CommandList list;
  final int oldIndex;
  final int newIndex;
  String get key => "CommandList.Move";

  MoveItem(this.list, this.oldIndex, this.newIndex);

  action() {
    var item = list._items.removeAt(oldIndex);
    list._items.insert(newIndex, item);
  }

  undoAction() {
    var item = list._items.removeAt(newIndex);
    list._items.insert(oldIndex, item);
  }
}
