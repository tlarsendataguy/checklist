import 'package:test/test.dart';
import 'package:checklist/src/checklist.dart';

main() {
  test("Creating a list without providing an ID generates a random ID", () {
    var list = new Checklist(name: "Test");
    expect(list.id, isNotNull);
    expect(list.id.length, greaterThan(0));
    print(
        "Random id from test 'Creating a list without providing an ID generates a random ID': ${list.id}");
  });

  test("Create a list with an existing id", () {
    var list = new Checklist(name: "Test", id: "000561804fcc009f61ce0002f95f0000");
    expect(list.id, equals("000561804fcc009f61ce0002f95f0000"));
  });

  test("Rename checklist", () {
    var list = new Checklist(name: "Awesome checklist");
    expect(list.name, equals("Awesome checklist"));

    var command = list.rename("Cool checklist");
    expect(list.name, equals("Cool checklist"));

    command.undo();
    expect(list.name, equals("Awesome checklist"));

    command.execute();
    expect(list.name, equals("Cool checklist"));
  });

  test("Add primary next checklist", () {
    var list1 = new Checklist(name: "Hello");
    var list2 = new Checklist(name: "World");

    var command = list1.setNextPrimary(list2);
    expect(list1.nextPrimary, equals(list2));

    command.undo();
    expect(list1.nextPrimary, isNull);

    command.execute();
    expect(list1.nextPrimary, equals(list2));
  });

  test("Add/remove alternative next checklists", () {
    var list1 = new Checklist(name: "Main");
    var list2 = new Checklist(name: "Alternative");

    var command = list1.nextAlternatives.insert(list2);
    expect(list1.nextAlternatives[0], equals(list2));
    expect(command.key, equals("NextAlternatives.Insert"));

    command.undo();
    expect(list1.nextAlternatives.length, equals(0));

    command.execute();
    expect(list1.nextAlternatives[0], equals(list2));
  });
}
