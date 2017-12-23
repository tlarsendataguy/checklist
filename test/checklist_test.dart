import 'package:test/test.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/item.dart';

main() {
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

    item = list.nextItem();
    expect(list.currentItem, isNull);
    expect(item, equals(null));
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

    item = list.nextItem(branch: true);
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

  test("Invalid history was provided to the play history method",(){
    throw new UnimplementedError("This test needs to be written");
  });
}

Checklist populatedList() {
  return new Checklist.fromSources([
    new Item("Item 1"),
    new Item("Item 2"),
    new Item("Item 3"),
  ]);
}

Checklist populatedBranchedList() {
  var branch = new Item("Item 2");
  branch.trueBranch.insert(new Item("True 1"));
  branch.trueBranch.insert(new Item("True 2"));
  branch.falseBranch.insert(new Item("False 1"));
  branch.falseBranch.insert(new Item("False 2"));

  return new Checklist.fromSources([
    new Item("Item 1"),
    branch,
    new Item("Item 3"),
  ]);
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
  |         |    -- Sub-Child 1
  |         |
  |         -- False Child 2
  |
  -- Item 2
 */

Checklist nestedBranchedList() {
  var branch1 = new Item("Parent Branch");
  var branch2 = new Item("Child Branch");

  branch1.trueBranch.insert(new Item("True Child 1"));
  branch1.trueBranch.insert(new Item("True Child 2"));
  branch1.falseBranch.insert(branch2);
  branch1.falseBranch.insert(new Item("False Child 2"));

  branch2.trueBranch.insert(new Item("Sub-Child 1"));

  return new Checklist.fromSources([
    new Item("Item 1"),
    branch1,
    new Item("Item 2"),
  ]);
}
