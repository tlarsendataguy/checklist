import 'package:checklist/src/book.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/item.dart';
import 'package:checklist/src/navigator.dart';
import 'package:test/test.dart';

main() {
  var startItem = new Item(toCheck: "Check 1", action: "Value 1");
  var item2 = new Item(toCheck: "Check 2", action: "Value 2");
  var startList = new Checklist(
    name: "Normal 1",
    source: [startItem],
  );
  var list2 = new Checklist(
    name: "Normal 2",
    source: [item2],
  );
  var book = new Book(
    name: "Navigation test",
    normalLists: [startList, list2],
  );

  test("Start book navigation", (){
    var navigator = new Navigator(book);
    expect(navigator.currentList, equals(startList));
    expect(navigator.priorList, isNull);
    expect(navigator.priorHistory, isNull);
  });

  test("Navigate to another list",(){
    var navigator = new Navigator(book);
    navigator.navigateTo(list2);
    expect(navigator.currentList, list2);
    expect(navigator.priorList, startList);
  });

  test("Move to the next item", () {
    var fixture = populatedListFixture();
    var list = fixture.list;
    var navigator = fixture.navigator;
    var item = navigator.nextItem();

    expect(navigator.currentItem, equals(list[1]));
    expect(item, equals(list[1]));
  });

  test("Move past the last item", () {
    var navigator = populatedListFixture().navigator;
    navigator.nextItem();
    navigator.nextItem();

    var item = navigator.nextItem();
    expect(navigator.currentItem, isNull);
    expect(item, equals(null));

    expect(
            () => navigator.nextItem(), throwsA(new isInstanceOf<UnsupportedError>()));
  });

  test("Move to the prior item", () {
    var fixture = populatedListFixture();
    var navigator = fixture.navigator;
    var list = fixture.list;
    navigator.nextItem();

    var item = navigator.priorItem();
    expect(navigator.currentItem, equals(list[0]));
    expect(item, equals(list[0]));
  });

  test("Move before the first item", () {
    var fixture = populatedListFixture();
    var navigator = fixture.navigator;
    var list = fixture.list;

    var item = navigator.priorItem();
    expect(navigator.currentItem, equals(list[0]));
    expect(item, equals(list[0]));
  });

  test("Branch items can only move next if true or false is specified", () {
    var navigator = populatedBranchedListFixture().navigator;
    navigator.nextItem();

    expect(
            () => navigator.nextItem(), throwsA(new isInstanceOf<UnsupportedError>()));
  });

  test(
      "Specifying true to move next on a branch causes the current item to be the first item in the true branch",
          () {
        var fixture = populatedBranchedListFixture();
        var navigator = fixture.navigator;
        navigator.nextItem();

        var shouldBe = fixture.list[1].trueBranch[0];

        var item = navigator.nextItem(branch: true);
        expect(item, equals(shouldBe));
        expect(navigator.currentItem, equals(shouldBe));
      });

  test(
      "Moving to the next item on the last item of a branch returns to the parent",
          () {
        var fixture = populatedBranchedListFixture();
        var navigator = fixture.navigator;
        navigator.nextItem();

        var shouldBe = fixture.list[2];

        navigator.nextItem(branch: true);
        navigator.nextItem();

        var item = navigator.nextItem();
        expect(item, equals(shouldBe));
        expect(navigator.currentItem, equals(shouldBe));
      });

  test(
      "Moving to prior item from the first item of a branch returns to the parent",
          () {
        var fixture = populatedBranchedListFixture();
        var shouldBe = fixture.list[1];
        var navigator = fixture.navigator;
        var list = fixture.list;

        navigator.nextItem();
        var item = navigator.nextItem(branch: true);

        expect(item, equals(list[1].trueBranch[0]));
        expect(navigator.currentItem, equals(list[1].trueBranch[0]));

        item = navigator.priorItem();

        expect(item, equals(shouldBe));
        expect(navigator.currentItem, shouldBe);
      });

  test("Move forward and back through nested branches, true", () {
    //Item 1 -> Parent Branch -> True Child 1 -> True Child 2 -> Item 2
    var navigator = nestedBranchedList().navigator;
    expect(navigator.currentItem.toCheck, equals("Item 1"));

    var item = navigator.nextItem();
    expect(item.toCheck, equals("Parent Branch"));

    item = navigator.nextItem(branch: true);
    expect(item.toCheck, equals("True Child 1"));

    item = navigator.nextItem();
    expect(item.toCheck, equals("True Child 2"));

    item = navigator.nextItem();
    expect(item.toCheck, equals("Item 2"));

    item = navigator.nextItem();
    expect(item, isNull);
  });

  test("Move forward and back through nested branches, false then true", () {
    //Item 1 -> Parent Branch -> Child Branch -> Sub-Child 1 -> False Child 2 -> Item 2
    var navigator = nestedBranchedList().navigator;
    expect(navigator.currentItem.toCheck, equals("Item 1"));

    var item = navigator.nextItem();
    expect(item.toCheck, equals("Parent Branch"));

    item = navigator.nextItem(branch: false);
    expect(item.toCheck, equals("Child Branch"));

    item = navigator.nextItem(branch: true);
    expect(item.toCheck, equals("Sub-Child 1"));

    item = navigator.nextItem();
    expect(item.toCheck, equals("False Child 2"));

    item = navigator.nextItem();
    expect(item.toCheck, equals("Item 2"));

    item = navigator.nextItem();
    expect(item, isNull);

    item = navigator.priorItem();
    expect(item.toCheck, equals("Item 2"));

    item = navigator.priorItem();
    expect(item.toCheck, equals("False Child 2"));

    item = navigator.priorItem();
    expect(item.toCheck, equals("Sub-Child 1"));

    item = navigator.priorItem();
    expect(item.toCheck, equals("Child Branch"));

    item = navigator.priorItem();
    expect(item.toCheck, equals("Parent Branch"));

    item = navigator.priorItem();
    expect(item.toCheck, equals("Item 1"));
  });

  test("Move forward and back through nested branches, false then false", () {
    //Item 1 -> Parent Branch -> Child Branch -> False Child 2 -> Item 2
    var navigator = nestedBranchedList().navigator;
    expect(navigator.currentItem.toCheck, equals("Item 1"));

    var item = navigator.nextItem();
    expect(item.toCheck, equals("Parent Branch"));

    item = navigator.nextItem(branch: false);
    expect(item.toCheck, equals("Child Branch"));

    item = navigator.nextItem(branch: false);
    expect(item.toCheck, equals("False Child 2"));

    item = navigator.nextItem();
    expect(item.toCheck, equals("Item 2"));

    item = navigator.nextItem();
    expect(item, isNull);
  });

  test("Specifying true or false on a non-branch is an error", () {
    var navigator = populatedBranchedListFixture().navigator;
    expect(() => navigator.nextItem(branch: true),
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

    var fixture1 = populatedBranchedListFixture();
    var testNavigator1 = fixture1.navigator;
    var testList1 = fixture1.list;
    testNavigator1.nextItem();
    expect(() => testNavigator1.playHistory(history1),
        throwsA(new isInstanceOf<ArgumentError>()));
    expect(testNavigator1.currentItem, equals(testList1[1]));

    var fixture2 = populatedBranchedListFixture();
    var testNavigator2 = fixture2.navigator;
    var testList2 = fixture2.list;
    testNavigator2.nextItem();
    expect((() => testNavigator2.playHistory(history2)),
        throwsA(new isInstanceOf<ArgumentError>()));
    expect(testNavigator2.currentItem, equals(testList2[1]));
  });
}

class NavigatorFixture {
  const NavigatorFixture(this.list,this.navigator);

  final Checklist list;
  final Navigator navigator;
}

NavigatorFixture populatedListFixture() {
  var list = Checklist(
    name: "Checklist",
    source: [
      new Item(toCheck: "Item 1"),
      new Item(toCheck: "Item 2"),
      new Item(toCheck: "Item 3"),
    ],
  );

  var book = Book(name: "Test", normalLists: [list]);
  return NavigatorFixture(list, Navigator(book));
}

NavigatorFixture populatedBranchedListFixture() {
  var branch = new Item(toCheck: "Item 2");
  branch.trueBranch.insert(new Item(toCheck: "True 1"));
  branch.trueBranch.insert(new Item(toCheck: "True 2"));
  branch.falseBranch.insert(new Item(toCheck: "False 1"));
  branch.falseBranch.insert(new Item(toCheck: "False 2"));


  var list = Checklist(
    name: "Checklist",
    source: [
      new Item(toCheck: "Item 1"),
      branch,
      new Item(toCheck: "Item 3"),
    ],
  );
  var navigator = Navigator(Book(name:"Test",normalLists: [list]));
  return NavigatorFixture(list, navigator);
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

NavigatorFixture nestedBranchedList() {
  var branch1 = new Item(toCheck: "Parent Branch");
  var branch2 = new Item(toCheck: "Child Branch");

  branch1.trueBranch.insert(new Item(toCheck: "True Child 1"));
  branch1.trueBranch.insert(new Item(toCheck: "True Child 2"));
  branch1.falseBranch.insert(branch2);
  branch1.falseBranch.insert(new Item(toCheck: "False Child 2"));

  branch2.trueBranch.insert(new Item(toCheck: "Sub-Child 1"));

  var list = new Checklist(
    name: "Checklist",
    source: [
      new Item(toCheck: "Item 1"),
      branch1,
      new Item(toCheck: "Item 2"),
    ],
  );
  var book = new Book(name: "Test", normalLists: [list]);
  return new NavigatorFixture(list,new Navigator(book));
}

