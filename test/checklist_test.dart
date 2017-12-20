import 'package:checklist/src/branch.dart';
import 'package:test/test.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/item.dart';
import 'package:checklist/src/command.dart';

main() {
  test("Current item of a new list is the first item", () {
    var list = populatedList();
    expect(list.currentIndex, equals(0));
  });

  test("Move to the next item", () {
    var list = populatedList();

    var item = list.nextItem();
    expect(list.currentIndex, equals(1));
    expect(item, equals(list[1]));
  });

  test("Move past the last item", () {
    var list = populatedList();
    list.nextItem();
    list.nextItem();

    var item = list.nextItem();
    expect(list.currentIndex, equals(3));
    expect(item, equals(null));

    item = list.nextItem();
    expect(list.currentIndex, equals(3));
    expect(item, equals(null));
  });

  test("Move to the prior item", () {
    var list = populatedList();
    list.nextItem();

    var item = list.priorItem();
    expect(list.currentIndex, equals(0));
    expect(item, equals(list[0]));
  });

  test("Move before the first item", () {
    var list = populatedList();

    var item = list.priorItem();
    expect(list.currentIndex, equals(0));
    expect(item, equals(list[0]));
  });

  test("Set current item explicitly", () {
    var list = populatedList();

    var item = list.setCurrent(2);
    expect(list.currentIndex, equals(2));
    expect(item, equals(list[2]));
  });

  test("Set current item to the list length", () {
    var list = populatedList();

    var item = list.setCurrent(3);
    expect(list.currentIndex, equals(3));
    expect(item, equals(null));
  });

  test("Set current item less than 0", () {
    var list = populatedList();
    expect(() => list.setCurrent(-1), throwsA(new isInstanceOf<RangeError>()));
    expect(list.currentIndex, equals(0));
  });

  test("Set current item greater than length", () {
    var list = populatedList();
    expect(() => list.setCurrent(5), throwsA(new isInstanceOf<RangeError>()));
    expect(list.currentIndex, equals(0));
  });

  test("Create an empty branch", () {
    var list = populatedList();

    var command = list.createBranchAt(1);
    Branch branch = list.branch(1);
    expect(list.branches, equals(1));
    expect(branch.lenTrue, equals(0));
    expect(branch.lenFalse, equals(0));

    command.undo();
    expect(list.branches, equals(0));

    command.redo();
    expect(list.branches, equals(1));
  });

  test("Create branch outside of valid range", () {
    var list = populatedList();

    expect(
      () => list.createBranchAt(5),
      throwsA(new isInstanceOf<RangeError>()),
    );
  });

  test("Create 2 branches at same location", () {
    var list = populatedList();
    list.createBranchAt(1);
    expect(
      () => list.createBranchAt(1),
      throwsA(new isInstanceOf<UnsupportedError>()),
    );
  });

  test("Delete an empty branch", () {
    var list = populatedBranchedList();

    var command = list.removeBranchAt(1);
    expect(list.branches, equals(0));

    command.undo();
    expect(list.branches, equals(1));

    command.redo();
    expect(list.branches, equals(0));
  });

  test("Remove a branch outside the normal range", () {
    var list = populatedBranchedList();

    expect(
        () => list.removeBranchAt(5), throwsA(new isInstanceOf<RangeError>()));
  });

  test("Remove a branch that does not exist at the specified location", () {
    var list = populatedList();

    expect(
      () => list.removeBranchAt(1),
      throwsA(new isInstanceOf<UnsupportedError>()),
    );
  });

  test("Add item into a True branch",(){
    var list = populatedBranchedList();
    var branch = list.branch(1);
    var item = new Item("True 1");

    var command = list.addTrueBranch(1,item);
    expect(list[2],equals(item));
    expect(branch.lenTrue,equals(1));
    expect(branch.lenFalse,equals(0));
    expect(list.length,equals(4));

    command.undo();
    expect(list[2].toCheck,equals("Item 3"));
    expect(branch.lenTrue, equals(0));
    expect(branch.lenFalse, equals(0));
    expect(list.length,equals(3));

    command.redo();
    expect(list[2],equals(item));
    expect(branch.lenTrue,equals(1));
    expect(branch.lenFalse,equals(0));
    expect(list.length,equals(4));
  });

  test("Adding item before branch updates the branch's index",(){
    var list = populatedBranchedList();

    var command = list.insert(new Item("I'm new here"),index: 0);
    expect(list.branch(1),isNull);
    expect(list.branch(2), isNotNull);

    command.undo();
    expect(list.branch(1),isNotNull);
    expect(list.branch(2), isNull);

    command.redo();
    expect(list.branch(1),isNull);
    expect(list.branch(2), isNotNull);
  });

  test("Removing item before branch updates the branch's index",(){
    var list = populatedBranchedList();
    var item = list[0];

    var command = list.remove(item);
    expect(list.branch(0), isNotNull);
    expect(list.branch(1), isNull);

    command.undo();
    expect(list.branch(0), isNull);
    expect(list.branch(1), isNotNull);

    command.redo();
    expect(list.branch(0), isNotNull);
    expect(list.branch(1), isNull);
  });

  test("Add item without specifying an index",(){
    fail("Not implemented");
  });

  test("Adding item in nested branch updates all parent branches",(){
    fail("Not implemented");
  });

  test("Removing item in nested branch updates all parent branches",(){
    fail("Not implemented");
  });

  test("Deleting an item deletes its branch",(){
    fail("Not implemented");
  });

  test("Deleting a branch deletes all items and branches in that branch",(){
    fail("Not implemented");
  });

  test("Inserting item in branch updates true/false len",(){
    fail("Not implemented");
  });

  test("Removing item from branch updates true/false len",(){
    fail("Not implemented");
  });

  test("Inserting item in nested branch updates all parent branches",(){
    fail("Not implemented");
  });

  test("Removing item from branch updates all parent branches",(){
    fail("Not implemented");
  });

  test("Moving a branch moves all of its children",(){
    fail("Not implemented");
  });

  test("Moving a branch moves all of its nested branches",(){
    fail("Not implemented");
  });
}

Checklist populatedList() {
  return new Checklist.fromSources(
    [
      new Item("Item 1"),
      new Item("Item 2"),
      new Item("Item 3"),
    ],
    new Map<int, Branch>(),
  );
}

Checklist populatedBranchedList() {
  return new Checklist.fromSources([
    new Item("Item 1"),
    new Item("Item 2"),
    new Item("Item 3"),
  ], {
    1: new Branch(lenTrue: 0, lenFalse: 0),
  });
}
