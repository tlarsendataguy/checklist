import 'package:test/test.dart';
import 'package:checklist/src/item.dart';
import 'package:command/command.dart';
import 'package:checklist/src/note.dart';

main() {
  test("Item getter works for all properties", () {
    var item = new Item("Airspeed", action: "150 KIAS");
    expect(item.toCheck, equals("Airspeed"));
    expect(item.action, equals("150 KIAS"));
  });

  test("When no action is provided, getter returns a zero-length string", () {
    var item = new Item("Airspeed");
    expect(item.action, equals(""));
    expect(item.action, isNotNull);
  });

  test("toCheck cannot be null", () {
    expect(
      () => new Item(null),
      throwsA(new isInstanceOf<ArgumentError>()),
    );
  });

  test("When action is null, getter returns a zero-length string", () {
    var item = new Item("Airspeed",action: null);
    expect(item.action, "");
  });

  test("Change the action", (){
    var item = new Item("Airspeed",action: "150 KIAS");
    item.setAction("100 KIAS");
    expect(item.action, "100 KIAS");
    expect(item.toCheck, "Airspeed");
  });

  test("Changing an action returns a command object", (){
    var item = new Item("Airspeed",action: "150 KIAS");
    var command = item.setAction("100 KIAS");
    expect(command, new isInstanceOf<Command>());
  });

  test("Changing action undo and redo work correctly",(){
    var item = new Item("Airspeed",action: "150 KIAS");
    var command = item.setAction("100 KIAS");
    expect(command.key, equals("Item.ChangeAction"));
    command.undo();
    expect(item.action,"150 KIAS");
    command.execute();
    expect(item.action,"100 KIAS");
  });

  test("Changing toCheck returns a command object", (){
    var item = new Item("Airspeed",action: "150 KIAS");
    var command = item.setToCheck("Cruise speed");
    expect(command, new isInstanceOf<Command>());
  });

  test("Changing toCheck undo and redo work correctly",(){
    var item = new Item("Airspeed",action: "150 KIAS");
    var command = item.setToCheck("Cruise speed");
    expect(command.key, equals("Item.ChangeToCheck"));
    command.undo();
    expect(item.toCheck, equals("Airspeed"));
    command.execute();
    expect(item.toCheck, equals("Cruise speed"));
  });

  test("Add item to and remove item from true branch",(){
    var item = new Item("Something");
    var command = item.trueBranch.insert(new Item("Something else"));
    expect(command.key,"TrueBranch.Insert");
    command = item.trueBranch.remove(item.trueBranch[0]);
    expect(command.key, "TrueBranch.Remove");
  });

  test("Add item to and remove item from false branch",() {
    var item = new Item("Something");
    var command = item.falseBranch.insert(new Item("Something else"));
    expect(command.key,"FalseBranch.Insert");
    command = item.falseBranch.remove(item.falseBranch[0]);
    expect(command.key, "FalseBranch.Remove");
  });

  test("An item that has at least 1 item in the True branch is a branch",(){
    var item = new Item("Test");
    expect(item.isBranch,isFalse);

    item.trueBranch.insert(new Item("True 1"));
    expect(item.isBranch, isTrue);
  });

  test("An item that has at least 1 item in the False branch is a branch",(){
    var item = new Item("Test");
    expect(item.isBranch, isFalse);

    item.falseBranch.insert(new Item("False 1"));
    expect(item.isBranch, isTrue);
  });

  test("Add a note to the item",(){
    var item = new Item("I have a note!");
    var note = new Note(Priority.Note,"I am a note!");
    var command = item.notes.insert(note);
    expect(item.notes[0], equals(note));
    expect(command.key,equals("Notes.Insert"));

    command.undo();
    expect(item.notes.length, equals(0));

    command.execute();
    expect(item.notes[0], equals(note));
  });

  test("Remove a note from an item",(){
    var item = new Item("I have a note!");
    var note = new Note(Priority.Note,"I am a note!");
    item.notes.insert(note);

    var command = item.notes.remove(note);
    expect(command.key, equals("Notes.Remove"));
    expect(item.notes.length, equals(0));

    command.undo();
    expect(item.notes[0], equals(note));

    command.execute();
    expect(item.notes.length, equals(0));
  });
}
