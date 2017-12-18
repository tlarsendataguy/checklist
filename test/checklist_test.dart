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

  test("Set current item greater than length",(){
    var list = populatedList();
    expect(() => list.setCurrent(5), throwsA(new isInstanceOf<RangeError>()));
    expect(list.currentIndex, equals(0));
  });
}

Checklist populatedList() {
  return new Checklist.fromIterable([
    new Item("Item 1"),
    new Item("Item 2"),
    new Item("Item 3"),
  ]);
}
