import 'package:checklist/src/book.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/diskwriter.dart';
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

  test("Deserialize JSON to Navigator", (){
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
  });
}

String removeNewLines(String json){
  return json.replaceAll(new RegExp(r"\n\s*", multiLine: true), "");
}
