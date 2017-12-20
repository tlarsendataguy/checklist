import 'package:checklist/src/command.dart';
import 'package:checklist/src/commandList.dart';
import 'package:test/test.dart';

class CommandListTester extends CommandList<String>{
  CommandListTester() : super();
  CommandListTester.fromIterable(Iterable<String> source) : super.fromIterable(source);
}

main(){
  test("Iterator works as expected", () {
    var list = populatedList();

    int i = 1;
    for (var item in list) {
      expect(item, equals("Item $i"));
      i++;
    }
  });

  test("Empty checklist iterates correctly", () {
    var list = new CommandListTester();
    int i = 0;
    for (var item in list) {
      i++;
    }

    expect(i, equals(0));
  });

  test("Add item to end checklist", () {
    var list = new CommandListTester();
    var command = list.insert("Item 1");

    expect(command, equals(new isInstanceOf<Command>()));
    expect(list[0], equals("Item 1"));

    command.undo();
    expect(list.length, 0);

    command.redo();
    expect(list[0], equals("Item 1"));
  });

  test("Insert item in the middle of the checklist", () {
    var list = populatedList();

    var command = list.insert("I'm new here", index: 1);

    expect(command, equals(new isInstanceOf<Command>()));
    expect(list[1], equals("I'm new here"));

    command.undo();
    expect(list[1], equals("Item 2"));

    command.redo();
    expect(list[1], equals("I'm new here"));
  });

  test("Insert item outside of range", () {
    var list = populatedList();

    expect(() => list.insert("I'm new here", index: 5),
        throwsA(new isInstanceOf<RangeError>()));
  });

  test("Delete item", () {
    var list = populatedList();
    var item = list[1];

    var command = list.remove(item);
    expect(list.length, equals(2));
    expect(list[0], equals("Item 1"));
    expect(list[1], equals("Item 3"));

    command.undo();
    expect(list.length, equals(3));
    expect(list[1], equals("Item 2"));

    command.redo();
    expect(list.length, equals(2));
    expect(list[0], equals("Item 1"));
    expect(list[1], equals("Item 3"));
  });

  test("Removing a non-existant item does not affect the list", () {
    var list = populatedList();
    var item = "I am not in the list";

    var command = list.remove(item);
    expect(list.length, equals(3));

    command.undo();
    expect(list.length, equals(3));

    command.redo();
    expect(list.length, equals(3));
  });

  test("Move an item to a new position", () {
    var list = populatedList();

    var command = list.moveItem(1, 2);
    expect(list[0], "Item 1");
    expect(list[1], "Item 3");
    expect(list[2], "Item 2");

    command.undo();
    expect(list[0], "Item 1");
    expect(list[1], "Item 2");
    expect(list[2], "Item 3");

    command.redo();
    expect(list[0], "Item 1");
    expect(list[1], "Item 3");
    expect(list[2], "Item 2");
  });

  test("Move an item with an invalid index", () {
    var list = populatedList();
    expect(() => list.moveItem(5, 1), throwsA(new isInstanceOf<RangeError>()));
  });

  test("Move an item to an invalid index", () {
    var list = populatedList();
    expect(() => list.moveItem(1, 5), throwsA(new isInstanceOf<RangeError>()));
  });

  test("Get the index of an element",(){
    var list = populatedList();
    var item = list[1];

    var index = list.indexOf(item);
    expect(index, equals(1));
  });

  test("Getting the index of a non-existent element returns -1",(){
    var list = populatedList();
    var item = "la la la";
    var index = list.indexOf(item);
    expect(index,equals(-1));
  });
}

CommandListTester populatedList() {
  return new CommandListTester.fromIterable([
    "Item 1",
    "Item 2",
    "Item 3",
  ]);
}