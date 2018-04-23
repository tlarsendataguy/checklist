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
  "currentList":"1",
  "priorList":null,
  "currentHistory":[
    {"index":0,"branch":null}
  ],
  "priorHistory":[]
}
""")));
  });

  test("Deserialize JSON with only current values",(){
    var json = """
{
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

  var invalidJson = '{"currentList":"2",priorList,"1","currentHistory":[],"priorHistory":[]}';

  test("Deserialize invalid JSON", () {
    var navigator = new Navigator(book);
    var io = new NavigatorIo(navigator, MockDiskWriter());

    expect(() => io.deserialize(invalidJson),
        throwsA(new isInstanceOf<MalformedStringException>()));
  });

  test("Deserializing invalid JSON reverts to original values", () {
    var navigator = new Navigator(book);
    var io = new NavigatorIo(navigator, MockDiskWriter());

    io.deserialize('{"currentList":"2","priorList":"1","currentHistory":[],"priorHistory":[{"index":0,"branch":null},{"index":0,"branch":null}]}');

    var currentList = book.normalLists[1];
    var priorList = book.normalLists[0];
    expect(navigator.currentList, equals(currentList));
    expect(navigator.currentItem, equals(currentList[0]));
    expect(navigator.priorList, equals(priorList));
    expect(navigator.readPriorHistory().length, equals(2));

    expect(()=> io.deserialize(invalidJson),
        throwsA(new isInstanceOf<MalformedStringException>()));

    expect(navigator.currentList, equals(currentList));
    expect(navigator.currentItem, equals(currentList[0]));
    expect(navigator.priorList, equals(priorList));
    expect(navigator.readPriorHistory().length, equals(2));

  });
}

String removeNewLines(String json) {
  return json.replaceAll(new RegExp(r"\n\s*", multiLine: true), "");
}
