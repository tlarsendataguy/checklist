import 'package:test/test.dart';
import 'package:checklist/src/container.dart';
import 'package:checklist/src/checklist.dart';

main() {
  test("Create a container with the specified name", () {
    var container = new Container("C172 Skyhawk");
    expect(container.name, equals("C172 Skyhawk"));
    expect(container.id.length, greaterThan(0));
    expect(container.normalLists.length, equals(0));
    expect(container.emergencyLists.length, equals(0));
  });

  test("Create a container with a specified ID", () {
    var container = new Container("C172 Skyhawk", id: '05a49c5890f824');
    expect(container.name, equals("C172 Skyhawk"));
    expect(container.id, equals("05a49c5890f824"));
  });

  test("Create a container with specified normal and emergency lists", () {
    var container = new Container(
      "C172 Skyhawk",
      normalLists: [
        new Checklist("Normal 1"),
        new Checklist("Normal 2"),
      ],
      emergencyLists: [
        new Checklist("Emergency 1"),
        new Checklist("Emergency 2"),
      ],
    );

    expect(container.normalLists.length, equals(2));
    expect(container.emergencyLists.length, equals(2));
    expect(container.normalLists[0].name, equals("Normal 1"));
    expect(container.normalLists[1].name, equals("Normal 2"));
    expect(container.emergencyLists[0].name, equals("Emergency 1"));
    expect(container.emergencyLists[1].name, equals("Emergency 2"));
  });

  test("Change container name",(){
    var container = new Container("Hello");
    expect(container.name, equals("Hello"));

    var command = container.changeName("Hi");
    expect(command.key,equals("Container.ChangeName"));
    expect(container.name, equals("Hi"));

    command.undo();
    expect(container.name, equals("Hello"));

    command.execute();
    expect(container.name, equals("Hi"));
  });
}
