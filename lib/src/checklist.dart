import 'package:checklist/src/item.dart';
import 'package:checklist/src/branch.dart';
import 'package:checklist/src/commandList.dart';

class Checklist extends CommandList<Item> {
  int _currentIndex = 0;
  var branches = new Branches();

  get currentIndex => _currentIndex;

  Checklist() : super();
  Checklist.fromIterable(Iterable<Item> source) : super.fromIterable(source);

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
      throw new RangeError(
          "Invalid value: Not in range 0..$length, inclusive: $newCurrent");
    }

    _currentIndex = newCurrent;
    if (newCurrent == length) {
      return null;
    } else {
      return this[_currentIndex];
    }
  }
}
