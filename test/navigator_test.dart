import 'package:checklist/src/book.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/item.dart';
import 'package:checklist/src/navigator.dart';
import 'package:test/test.dart';

main() {
  var startItem = new Item(toCheck: "Check 1", action: "Value 1");
  var item2 = new Item(toCheck: "Check 2", action: "Value 2");
  var item3 = new Item(toCheck: "Check 3", action: "Value 3");
  var item4 = new Item(toCheck: "Check 4", action: "Value 4");
  var startList = new Checklist(
    name: "Normal 1",
    source: [startItem, item2],
  );
  var list2 = new Checklist(
    name: "Normal 2",
    source: [item3, item4],
  );
  var book = new Book(
    name: "Navigation test",
    normalLists: [startList, list2],
  );

  test("Test canMoveNext and canGoBack",(){
    var navigator = new Navigator(book);

    expect(navigator.canMoveNext, isTrue);
    expect(navigator.canGoBack, isFalse);

    navigator.moveNext();

    expect(navigator.canMoveNext, isTrue);
    expect(navigator.canGoBack, isTrue);

    navigator.moveNext();

    expect(navigator.canMoveNext, isFalse);
    expect(navigator.canGoBack, isTrue);

    navigator.goBack();

    expect(navigator.canMoveNext, isTrue);
    expect(navigator.canGoBack, isTrue);

    navigator.goBack();

    expect(navigator.canMoveNext, isTrue);
    expect(navigator.canGoBack, isFalse);
  });

  test("Move to the next item", () {
    var fixture = populatedListFixture();
    var list = fixture.list;
    var navigator = fixture.navigator;
    var item = navigator.moveNext();

    expect(navigator.currentItem, equals(list[1]));
    expect(item, equals(list[1]));
  });

  test("Move past the last item", () {
    var navigator = populatedListFixture().navigator;
    navigator.moveNext();
    navigator.moveNext();

    var item = navigator.moveNext();
    expect(navigator.currentItem, isNull);
    expect(item, equals(null));

    expect(
            () => navigator.moveNext(), throwsA(new isInstanceOf<UnsupportedError>()));
  });

  test("Move to the prior item", () {
    var fixture = populatedListFixture();
    var navigator = fixture.navigator;
    var list = fixture.list;
    navigator.moveNext();

    var item = navigator.goBack();
    expect(navigator.currentItem, equals(list[0]));
    expect(item, equals(list[0]));
  });

  test("Move before the first item", () {
    var fixture = populatedListFixture();
    var navigator = fixture.navigator;
    var list = fixture.list;

    var item = navigator.goBack();
    expect(navigator.currentItem, equals(list[0]));
    expect(item, equals(list[0]));
  });

  test("Branch items can only move next if true or false is specified", () {
    var navigator = populatedBranchedListFixture().navigator;
    navigator.moveNext();

    expect(
            () => navigator.moveNext(), throwsA(new isInstanceOf<UnsupportedError>()));
  });

  test(
      "Specifying true to move next on a branch causes the current item to be the first item in the true branch",
          () {
        var fixture = populatedBranchedListFixture();
        var navigator = fixture.navigator;
        navigator.moveNext();

        var shouldBe = fixture.list[1].trueBranch[0];

        var item = navigator.moveNext(branch: true);
        expect(item, equals(shouldBe));
        expect(navigator.currentItem, equals(shouldBe));
      });

  test(
      "Moving to the next item on the last item of a branch returns to the parent",
          () {
        var fixture = populatedBranchedListFixture();
        var navigator = fixture.navigator;
        navigator.moveNext();

        var shouldBe = fixture.list[2];

        navigator.moveNext(branch: true);
        navigator.moveNext();

        var item = navigator.moveNext();
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

        navigator.moveNext();
        var item = navigator.moveNext(branch: true);

        expect(item, equals(list[1].trueBranch[0]));
        expect(navigator.currentItem, equals(list[1].trueBranch[0]));

        item = navigator.goBack();

        expect(item, equals(shouldBe));
        expect(navigator.currentItem, shouldBe);
      });

  test("Move forward and back through nested branches, true", () {
    //Item 1 -> Parent Branch -> True Child 1 -> True Child 2 -> Item 2
    var navigator = nestedBranchedList().navigator;
    expect(navigator.currentItem.toCheck, equals("Item 1"));

    var item = navigator.moveNext();
    expect(item.toCheck, equals("Parent Branch"));

    item = navigator.moveNext(branch: true);
    expect(item.toCheck, equals("True Child 1"));

    item = navigator.moveNext();
    expect(item.toCheck, equals("True Child 2"));

    item = navigator.moveNext();
    expect(item.toCheck, equals("Item 2"));

    item = navigator.moveNext();
    expect(item, isNull);

    item = navigator.goBack();
    expect(item.toCheck, equals("Item 2"));

    item = navigator.goBack();
    expect(item.toCheck, equals("True Child 2"));

    item = navigator.goBack();
    expect(item.toCheck, equals("True Child 1"));

    item = navigator.goBack();
    expect(item.toCheck, equals("Parent Branch"));

    item = navigator.goBack();
    expect(item.toCheck, equals("Item 1"));
  });

  test("Move forward and back through nested branches, false then true", () {
    //Item 1 -> Parent Branch -> Child Branch -> Sub-Child 1 -> False Child 2 -> Item 2
    var navigator = nestedBranchedList().navigator;
    expect(navigator.currentItem.toCheck, equals("Item 1"));

    var item = navigator.moveNext();
    expect(item.toCheck, equals("Parent Branch"));

    item = navigator.moveNext(branch: false);
    expect(item.toCheck, equals("Child Branch"));

    item = navigator.moveNext(branch: true);
    expect(item.toCheck, equals("Sub-Child 1"));

    item = navigator.moveNext();
    expect(item.toCheck, equals("False Child 2"));

    item = navigator.moveNext();
    expect(item.toCheck, equals("Item 2"));

    item = navigator.moveNext();
    expect(item, isNull);

    item = navigator.goBack();
    expect(item.toCheck, equals("Item 2"));

    item = navigator.goBack();
    expect(item.toCheck, equals("False Child 2"));

    item = navigator.goBack();
    expect(item.toCheck, equals("Sub-Child 1"));

    item = navigator.goBack();
    expect(item.toCheck, equals("Child Branch"));

    item = navigator.goBack();
    expect(item.toCheck, equals("Parent Branch"));

    item = navigator.goBack();
    expect(item.toCheck, equals("Item 1"));
  });

  test("Move forward and back through nested branches, false then false", () {
    //Item 1 -> Parent Branch -> Child Branch -> False Child 2 -> Item 2
    var navigator = nestedBranchedList().navigator;
    expect(navigator.currentItem.toCheck, equals("Item 1"));

    var item = navigator.moveNext();
    expect(item.toCheck, equals("Parent Branch"));

    item = navigator.moveNext(branch: false);
    expect(item.toCheck, equals("Child Branch"));

    item = navigator.moveNext(branch: false);
    expect(item.toCheck, equals("False Child 2"));

    item = navigator.moveNext();
    expect(item.toCheck, equals("Item 2"));

    item = navigator.moveNext();
    expect(item, isNull);

    item = navigator.goBack();
    expect(item.toCheck, equals("Item 2"));

    item = navigator.goBack();
    expect(item.toCheck, equals("False Child 2"));

    item = navigator.goBack();
    expect(item.toCheck, equals("Child Branch"));

    item = navigator.goBack();
    expect(item.toCheck, equals("Parent Branch"));

    item = navigator.goBack();
    expect(item.toCheck, equals("Item 1"));
  });

  test("Specifying true or false on a non-branch is an error", () {
    var navigator = populatedBranchedListFixture().navigator;
    expect(() => navigator.moveNext(branch: true),
        throwsA(new isInstanceOf<UnsupportedError>()));
  });

  test("Invalid history was provided to the play history method", () {
    //History that doesn't specify branch when needed
    var history1 = [
      new NavigationHistory(0, null),
      new NavigationHistory(1, null),
      new NavigationHistory(2, null),
    ];

    //History that is longer than the list
    var history2 = [
      new NavigationHistory(0, null),
      new NavigationHistory(1, null),
      new NavigationHistory(2, null),
      new NavigationHistory(3, null),
    ];

    var fixture1 = populatedBranchedListFixture();
    var testNavigator1 = fixture1.navigator;
    var testList1 = fixture1.list;
    testNavigator1.moveNext();
    expect(() => testNavigator1.playHistory(history1),
        throwsA(new isInstanceOf<ArgumentError>()));
    expect(testNavigator1.currentItem, equals(testList1[1]));

    var fixture2 = populatedBranchedListFixture();
    var testNavigator2 = fixture2.navigator;
    var testList2 = fixture2.list;
    testNavigator2.moveNext();
    expect((() => testNavigator2.playHistory(history2)),
        throwsA(new isInstanceOf<ArgumentError>()));
    expect(testNavigator2.currentItem, equals(testList2[1]));
  });

  test("Start book navigation", (){
    var navigator = new Navigator(book);
    expect(navigator.currentList, equals(startList));
    expect(navigator.priorList, isNull);
  });

  test("Navigate to another list",(){
    var navigator = new Navigator(book);
    navigator.changeList(list2);
    expect(navigator.currentList, list2);
    expect(navigator.priorList, startList);
  });

  test("Go back after navigating to the second item of a new list",(){
    var navigator = new Navigator(book);

    navigator.moveNext();
    navigator.changeList(list2);
    navigator.moveNext();

    expect(navigator.canGoBack, isTrue);

    navigator.goBack();

    expect(navigator.canGoBack, isTrue);
    expect(navigator.currentList, equals(list2));
    expect(navigator.priorList, equals(startList));
    expect(navigator.readPriorHistory().length, equals(1));

    navigator.goBack();

    expect(navigator.canGoBack, isTrue);
    expect(navigator.currentList, equals(startList));
    expect(navigator.priorList, isNull);
    expect(navigator.readPriorHistory().length, equals(0));
    expect(navigator.readCurrentHistory().length, equals(1));

    navigator.goBack();

    expect(navigator.canGoBack, isFalse);
  });

  test("Create navigator with empty book",(){
    var navigator = new Navigator(new Book(name: "Empty"));

    expect(navigator.canGoBack, isFalse);
    expect(navigator.canMoveNext, isFalse);
    expect(navigator.currentList, isNull);
    expect(navigator.priorList, isNull);
    expect(navigator.currentItem, isNull);
  });

  test("Create navigator with empty first list", (){
    var navigator = new Navigator(
      new Book(
        name: "Empty first list",
        normalLists: [
          new Checklist(name: "Empty"),
        ],
      ),
    );

    expect(navigator.canGoBack, isFalse);
    expect(navigator.canMoveNext, isFalse);
    expect(navigator.currentList, isNotNull);
    expect(navigator.priorList, isNull);
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

