import 'dart:io';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/diskwriter.dart';
import 'package:checklist/src/exceptions.dart';
import 'package:checklist/src/item.dart';
import 'package:checklist/src/navigator.dart';
import 'package:checklist/src/navigatorio.dart';
import 'package:test/test.dart';

main() {
  var book = new Book(
    id: "12345",
    name: "Navigator IO Test",
    normalLists: [
      new Checklist(
        id: "1",
        name: "List 1",
        source: [
          new Item(toCheck: "Item 1.1"),
          new Item(toCheck: "Item 1.2"),
        ],
      ),
      new Checklist(
        id: "2",
        name: "List 2",
        source: [
          new Item(toCheck: "Item 2.1"),
          new Item(toCheck: "Item 2.2"),
        ],
      ),
    ],
  );

  test("Serialize navigator to JSON", () {
    var navigator = new Navigator(book);
    var io = new NavigatorIo(navigator, new MockDiskWriter());
    var json = io.serialize();
    expect(json, equals(removeNewLines("""
{
  "book":"12345",
  "currentList":"1",
  "priorList":null,
  "currentHistory":[],
  "priorHistory":[]
}
""")));

    navigator.moveNext();
    json = io.serialize();

    expect(json, equals(removeNewLines("""
{
  "book":"12345",
  "currentList":"1",
  "priorList":null,
  "currentHistory":[
    {"index":0,"branch":null}
  ],
  "priorHistory":[]
}
""")));

    navigator.changeList(book.normalLists[1]);
    json = io.serialize();

    expect(json, equals(removeNewLines("""
{
  "book":"12345",
  "currentList":"2",
  "priorList":"1",
  "currentHistory":[],
  "priorHistory":[
    {"index":0,"branch":null}
  ]
}
""")));

    navigator.moveNext();
    json = io.serialize();

    expect(json, equals(removeNewLines("""
{
  "book":"12345",
  "currentList":"2",
  "priorList":"1",
  "currentHistory":[
    {"index":0,"branch":null}
  ],
  "priorHistory":[
    {"index":0,"branch":null}
  ]
}
""")));

    navigator.goBack();
    navigator.goBack();
    json = io.serialize();

    expect(json, equals(removeNewLines("""
{
  "book":"12345",
  "currentList":"1",
  "priorList":null,
  "currentHistory":[
    {"index":0,"branch":null}
  ],
  "priorHistory":[]
}
""")));
  });

  test("Deserialize JSON with only current values", () {
    var json = """
{
  "book":"12345",
  "currentList":"1",
  "priorList":null,
  "currentHistory":[
    {"index":0,"branch":null}
  ],
  "priorHistory":[]
}
""";

    var navigator = new Navigator(book);
    var io = new NavigatorIo(navigator, MockDiskWriter());
    io.deserialize(json);
    expect(navigator.currentList, equals(book.normalLists[0]));
    expect(navigator.priorList, isNull);
    expect(navigator.readCurrentHistory().length, equals(1));
    expect(navigator.readPriorHistory().length, equals(0));
  });

  test("Deserialize JSON with current and prior values", () {
    var json = """
{
  "book":"12345",
  "currentList":"2",
  "priorList":"1",
  "currentHistory":[
    {"index":0,"branch":null}
  ],
  "priorHistory":[
    {"index":0,"branch":null}
  ]
}
""";

    var navigator = new Navigator(book);
    var io = new NavigatorIo(navigator, MockDiskWriter());
    io.deserialize(json);
    expect(navigator.currentList, equals(book.normalLists[1]));
    expect(navigator.priorList, equals(book.normalLists[0]));
    expect(navigator.readCurrentHistory().length, equals(1));
    expect(navigator.readPriorHistory().length, equals(1));
  });

  var invalidJson =
      '{"book":"12345","currentList":"2",priorList,"1","currentHistory":[],"priorHistory":[]}';

  test("Deserialize invalid JSON", () {
    var navigator = new Navigator(book);
    var io = new NavigatorIo(navigator, MockDiskWriter());

    expect(() => io.deserialize(invalidJson),
        throwsA(new isInstanceOf<MalformedStringException>()));
  });

  test("Deserializing invalid JSON reverts to original values", () {
    var navigator = new Navigator(book);
    var io = new NavigatorIo(navigator, MockDiskWriter());

    io.deserialize(
        '{"book":"12345","currentList":"2","priorList":"1","currentHistory":[],"priorHistory":[{"index":0,"branch":null},{"index":0,"branch":null}]}');

    var currentList = book.normalLists[1];
    var priorList = book.normalLists[0];
    expect(navigator.currentList, equals(currentList));
    expect(navigator.currentItem, equals(currentList[0]));
    expect(navigator.priorList, equals(priorList));
    expect(navigator.readPriorHistory().length, equals(2));

    expect(() => io.deserialize(invalidJson),
        throwsA(new isInstanceOf<MalformedStringException>()));

    expect(navigator.currentList, equals(currentList));
    expect(navigator.currentItem, equals(currentList[0]));
    expect(navigator.priorList, equals(priorList));
    expect(navigator.readPriorHistory().length, equals(2));
  });

  test("Serialize and deserialize a file", () async {
    var navigator = new Navigator(book);
    var io = new NavigatorIo(navigator, MockDiskWriter());

    var file = new File("Navigator.json");

    if (await file.exists()) {
      await file.delete(recursive: true);
    }

    expect(await file.exists(), isFalse);

    navigator.moveNext();
    await io.persist();
    expect(await file.exists(), isTrue);

    var newNavigator = new Navigator(book);
    var newIo = new NavigatorIo(newNavigator, MockDiskWriter());
    var success = await newIo.retrieve();
    expect(success, isTrue);
    expect(newNavigator.currentList.name, equals(navigator.currentList.name));
    expect(
      newNavigator.currentList.indexOf(newNavigator.currentItem),
      equals(navigator.currentList.indexOf(navigator.currentItem)),
    );

    await file.delete(recursive: true);
  });

  test("Deserialize a file for a different book",() async {
    var navigator = new Navigator(book);
    var io = new NavigatorIo(navigator, MockDiskWriter());

    var file = new File("Navigator.json");

    await io.persist();

    var newNavigator = new Navigator(new Book(id: "67890",name: "Blah"));
    var newIo = new NavigatorIo(newNavigator, MockDiskWriter());
    var success = await newIo.retrieve();
    expect(success, isFalse);

    await file.delete(recursive: true);
  });

  test("Deserialize a file that does not exist",() async {
    var file = new File("Navigator.json");
    if (await file.exists()) await file.delete(recursive: true);

    var navigator = new Navigator(book);
    var io = new NavigatorIo(navigator, MockDiskWriter());
    var success = await io.retrieve();
    expect(success, isFalse);
  });

  test("Delete the file",() async {
    var navigator = new Navigator(book);
    var io = new NavigatorIo(navigator, MockDiskWriter());

    var file = new File("Navigator.json");

    await io.delete();
    expect(await file.exists(), isFalse);
  });
}

String removeNewLines(String json) {
  return json.replaceAll(new RegExp(r"\n\s*", multiLine: true), "");
}
