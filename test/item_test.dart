import 'package:test/test.dart';
import 'package:checklist/src/item.dart';
import 'package:checklist/src/command.dart';

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
    command.undo();
    expect(item.action,"150 KIAS");
    command.redo();
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
    command.undo();
    expect(item.toCheck, equals("Airspeed"));
    command.redo();
    expect(item.toCheck, equals("Cruise speed"));
  });
}
