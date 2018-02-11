import 'package:test/test.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/item.dart';

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

  test("Current item of a new list is the first item", () {
    var list = populatedList();
    expect(list.currentItem, equals(list[0]));
  });

  test("Move to the next item", () {
    var list = populatedList();

    var item = list.nextItem();
    expect(list.currentItem, equals(list[1]));
    expect(item, equals(list[1]));
  });

  test("Move past the last item", () {
    var list = populatedList();
    list.nextItem();
    list.nextItem();

    var item = list.nextItem();
    expect(list.currentItem, isNull);
    expect(item, equals(null));

    expect(
        () => list.nextItem(), throwsA(new isInstanceOf<UnsupportedError>()));
  });

  test("Move to the prior item", () {
    var list = populatedList();
    list.nextItem();

    var item = list.priorItem();
    expect(list.currentItem, equals(list[0]));
    expect(item, equals(list[0]));
  });

  test("Move before the first item", () {
    var list = populatedList();

    var item = list.priorItem();
    expect(list.currentItem, equals(list[0]));
    expect(item, equals(list[0]));
  });

  test("Branch items can only move next if true or false is specified", () {
    var list = populatedBranchedList();
    list.nextItem();

    expect(
        () => list.nextItem(), throwsA(new isInstanceOf<UnsupportedError>()));
  });

  test(
      "Specifying true to move next on a branch causes the current item to be the first item in the true branch",
      () {
    var list = populatedBranchedList();
    list.nextItem();

    var shouldBe = list[1].trueBranch[0];

    var item = list.nextItem(branch: true);
    expect(item, equals(shouldBe));
    expect(list.currentItem, equals(shouldBe));
  });

  test(
      "Moving to the next item on the last item of a branch returns to the parent",
      () {
    var list = populatedBranchedList();
    list.nextItem();

    var shouldBe = list[2];

    list.nextItem(branch: true);
    list.nextItem();

    var item = list.nextItem();
    expect(item, equals(shouldBe));
    expect(list.currentItem, equals(shouldBe));
  });

  test(
      "Moving to prior item from the first item of a branch returns to the parent",
      () {
    var list = populatedBranchedList();
    var shouldBe = list[1];

    list.nextItem();
    var item = list.nextItem(branch: true);

    expect(item, equals(list[1].trueBranch[0]));
    expect(list.currentItem, equals(list[1].trueBranch[0]));

    item = list.priorItem();

    expect(item, equals(shouldBe));
    expect(list.currentItem, shouldBe);
  });

  test("Move forward and back through nested branches, true", () {
    //Item 1 -> Parent Branch -> True Child 1 -> True Child 2 -> Item 2
    var list = nestedBranchedList();
    expect(list.currentItem.toCheck, equals("Item 1"));

    var item = list.nextItem();
    expect(item.toCheck, equals("Parent Branch"));

    item = list.nextItem(branch: true);
    expect(item.toCheck, equals("True Child 1"));

    item = list.nextItem();
    expect(item.toCheck, equals("True Child 2"));

    item = list.nextItem();
    expect(item.toCheck, equals("Item 2"));

    item = list.nextItem();
    expect(item, isNull);
  });

  test("Move forward and back through nested branches, false then true", () {
    //Item 1 -> Parent Branch -> Child Branch -> Sub-Child 1 -> False Child 2 -> Item 2
    var list = nestedBranchedList();
    expect(list.currentItem.toCheck, equals("Item 1"));

    var item = list.nextItem();
    expect(item.toCheck, equals("Parent Branch"));

    item = list.nextItem(branch: false);
    expect(item.toCheck, equals("Child Branch"));

    item = list.nextItem(branch: true);
    expect(item.toCheck, equals("Sub-Child 1"));

    item = list.nextItem();
    expect(item.toCheck, equals("False Child 2"));

    item = list.nextItem();
    expect(item.toCheck, equals("Item 2"));

    item = list.nextItem();
    expect(item, isNull);

    item = list.priorItem();
    expect(item.toCheck, equals("Item 2"));

    item = list.priorItem();
    expect(item.toCheck, equals("False Child 2"));

    item = list.priorItem();
    expect(item.toCheck, equals("Sub-Child 1"));

    item = list.priorItem();
    expect(item.toCheck, equals("Child Branch"));

    item = list.priorItem();
    expect(item.toCheck, equals("Parent Branch"));

    item = list.priorItem();
    expect(item.toCheck, equals("Item 1"));
  });

  test("Move forward and back through nested branches, false then false", () {
    //Item 1 -> Parent Branch -> Child Branch -> False Child 2 -> Item 2
    var list = nestedBranchedList();
    expect(list.currentItem.toCheck, equals("Item 1"));

    var item = list.nextItem();
    expect(item.toCheck, equals("Parent Branch"));

    item = list.nextItem(branch: false);
    expect(item.toCheck, equals("Child Branch"));

    item = list.nextItem(branch: false);
    expect(item.toCheck, equals("False Child 2"));

    item = list.nextItem();
    expect(item.toCheck, equals("Item 2"));

    item = list.nextItem();
    expect(item, isNull);
  });

  test("Specifying true or false on a non-branch is an error", () {
    var list = populatedBranchedList();
    expect(() => list.nextItem(branch: true),
        throwsA(new isInstanceOf<UnsupportedError>()));
  });

  test("Invalid history was provided to the play history method", () {
    //History that doesn't specify branch when needed
    var history1 = [
      new BranchHistory(0, null),
      new BranchHistory(1, null),
      new BranchHistory(2, null),
    ];

    //History that is longer than the list
    var history2 = [
      new BranchHistory(0, null),
      new BranchHistory(1, null),
      new BranchHistory(2, null),
      new BranchHistory(3, null),
    ];

    var testList1 = populatedBranchedList();
    testList1.nextItem();
    expect(() => testList1.playHistory(history1),
        throwsA(new isInstanceOf<ArgumentError>()));
    expect(testList1.currentItem, equals(testList1[1]));

    var testList2 = populatedList();
    testList2.nextItem();
    expect((() => testList2.playHistory(history2)),
        throwsA(new isInstanceOf<ArgumentError>()));
    expect(testList2.currentItem, equals(testList2[1]));
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

Checklist populatedList() {
  return new Checklist(
    name: "Checklist",
    source: [
      new Item(toCheck: "Item 1"),
      new Item(toCheck: "Item 2"),
      new Item(toCheck: "Item 3"),
    ],
  );
}

Checklist populatedBranchedList() {
  var branch = new Item(toCheck: "Item 2");
  branch.trueBranch.insert(new Item(toCheck: "True 1"));
  branch.trueBranch.insert(new Item(toCheck: "True 2"));
  branch.falseBranch.insert(new Item(toCheck: "False 1"));
  branch.falseBranch.insert(new Item(toCheck: "False 2"));

  return new Checklist(
    name: "Checklist",
    source: [
      new Item(toCheck: "Item 1"),
      branch,
      new Item(toCheck: "Item 3"),
    ],
  );
}

/*
Structure of the returned nested-branch checklist:

Checklist
  |
  -- Item 1
  |
  -- Parent Branch
  |    |
  |    -- True
  |    |    |
  |    |    -- True Child 1
  |    |    |
  |    |    -- True child 2
  |    |
  |    -- False
  |         |
  |         -- Child Branch
  |         |    |
  |         |    -- True
  |         |        |
  |         |        -- Sub-Child 1
  |         |
  |         -- False Child 2
  |
  -- Item 2
 */

Checklist nestedBranchedList() {
  var branch1 = new Item(toCheck: "Parent Branch");
  var branch2 = new Item(toCheck: "Child Branch");

  branch1.trueBranch.insert(new Item(toCheck: "True Child 1"));
  branch1.trueBranch.insert(new Item(toCheck: "True Child 2"));
  branch1.falseBranch.insert(branch2);
  branch1.falseBranch.insert(new Item(toCheck: "False Child 2"));

  branch2.trueBranch.insert(new Item(toCheck: "Sub-Child 1"));

  return new Checklist(
    name: "Checklist",
    source: [
      new Item(toCheck: "Item 1"),
      branch1,
      new Item(toCheck: "Item 2"),
    ],
  );
}
