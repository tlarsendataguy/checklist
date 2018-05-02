import 'package:checklist/src/exceptions.dart';
import 'package:checklist/src/serializer.dart';
import 'package:test/test.dart';
import 'package:checklist/src/book.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/item.dart';
import 'package:checklist/src/note.dart';

main() {
  test("Serialize book to JSON string", () {
    var book = generateBook();
    var string = Serializer.serialize(book);
    var shouldEqual =
        serializedString.replaceAll(new RegExp(r"\n\s+", multiLine: true), "");
    expect(string, equals(shouldEqual));
  });

  test("Deserialize JSON string to book", () {
    var string =
        serializedString.replaceAll(new RegExp(r"\n\s+", multiLine: true), "");
    var book = Serializer.deserialize(string);
    expect(book.name, equals("My fancy new book"));
    expect(book.id, equals("MyContainer123"));
    expect(book.normalLists.length, equals(3));

    for (int i = 0; i < book.normalLists.length; i++) {
      int j = i + 1;
      expect(book.normalLists[i].name, equals("Normal $j"));
      expect(book.normalLists[i].id, equals("ListId$j"));
    }

    expect(book.emergencyLists.length, equals(1));
    expect(book.emergencyLists[0].name, equals("Emergency 1"));
    expect(book.emergencyLists[0].id, equals("ListId4"));

    var list = book.normalLists[0];
    expect(list.length, equals(3));
    expect(list.nextPrimary, equals(book.normalLists[1]));
    expect(list.nextAlternatives.length, equals(1));
    expect(list.nextAlternatives[0], equals(book.normalLists[2]));

    var item = list[0];
    expect(item.toCheck, equals("Item 1"));
    expect(item.action, equals("Verified"));
    expect(item.isBranch, equals(true));
    expect(item.trueBranch.length, equals(2));
    expect(item.falseBranch.length, equals(1));
    expect(item.notes.length, equals(2));

    var note = item.notes[0];
    expect(note.priority, equals(Priority.Note));
    expect(note.text, equals("Note 1"));

    note = item.notes[1];
    expect(note.priority, equals(Priority.Warning));
    expect(note.text, equals("Note 2"));

    var subitem = item.trueBranch[0];
    expect(subitem.toCheck, equals("Item 2"));
    expect(subitem.action, equals(""));
    expect(subitem.isBranch, equals(false));
    expect(subitem.notes[0], equals(item.notes[0]));

    subitem = item.trueBranch[1];
    expect(subitem.toCheck, equals("Item 3"));
    expect(subitem.action, equals(""));
    expect(subitem.isBranch, equals(false));

    subitem = item.falseBranch[0];
    expect(subitem.toCheck, equals("Item 4"));
    expect(subitem.action, equals(""));
    expect(subitem.isBranch, equals(false));

    item = list[1];
    expect(item.toCheck, equals("Item 5"));
    expect(item.action, equals(""));
    expect(item.isBranch, equals(false));

    item = list[2];
    expect(item.toCheck, equals("Item 6"));
    expect(item.action, equals(""));
    expect(item.isBranch, equals(false));

    note = item.notes[0];
    expect(note.priority, equals(Priority.Caution));
    expect(note.text, equals("Note 3"));

    list = book.normalLists[1];
    expect(list.length, equals(2));
    expect(list.nextPrimary, isNull);
    expect(list.nextAlternatives.length, equals(0));

    item = list[0];
    expect(item.toCheck, equals("Item 7"));
    expect(item.action, equals(""));
    expect(item.isBranch, equals(false));

    item = list[1];
    expect(item.toCheck, equals("Item 8"));
    expect(item.action, equals(""));
    expect(item.isBranch, equals(false));

    list = book.normalLists[2];
    expect(list.length, equals(2));
    expect(list.nextPrimary, isNull);
    expect(list.nextAlternatives.length, equals(0));

    item = list[0];
    expect(item.toCheck, equals("Item 9"));
    expect(item.action, equals(""));
    expect(item.isBranch, equals(false));

    item = list[1];
    expect(item.toCheck, equals("Item 10"));
    expect(item.action, equals(""));
    expect(item.isBranch, equals(false));

    list = book.emergencyLists[0];
    expect(list.length, equals(2));
    expect(list.nextPrimary, isNull);
    expect(list.nextAlternatives.length, equals(0));

    item = list[0];
    expect(item.toCheck, equals("Item 11"));
    expect(item.action, equals(""));
    expect(item.isBranch, equals(false));

    item = list[1];
    expect(item.toCheck, equals("Item 12"));
    expect(item.action, equals(""));
    expect(item.isBranch, equals(false));
  });

  test("Deserialize malformed JSON string", () {
    var string = "lksjg)(UWTIgjlkdjgsdg";
    expect(
      () => Serializer.deserialize(string),
      throwsA(new isInstanceOf<MalformedStringException>()),
    );
  });

  test("Deserialize JSON string with incorrect properties", () {
    var string = '{"property":"value"}';
    expect(
      () => Serializer.deserialize(string),
      throwsA(new isInstanceOf<MalformedStringException>()),
    );
  });
}

Book generateBook() {
  Checklist list2 = new Checklist(
    name: "Normal 2",
    id: "ListId2",
    source: [
      new Item(toCheck: "Item 7"),
      new Item(toCheck: "Item 8"),
    ],
  );
  Checklist list3 = new Checklist(
    name: "Normal 3",
    id: "ListId3",
    source: [
      new Item(toCheck: "Item 9"),
      new Item(toCheck: "Item 10"),
    ],
  );

  Checklist list1 = new Checklist(
    name: "Normal 1",
    id: "ListId1",
    source: [
      new Item(
        toCheck: "Item 1",
        action: "Verified",
        trueBranch: [
          new Item(toCheck: "Item 2", notes: [new Note(Priority.Note, "Note 1")]),
          new Item(toCheck: "Item 3"),
        ],
        falseBranch: [
          new Item(toCheck: "Item 4"),
        ],
        notes: [
          new Note(Priority.Note, "Note 1"),
          new Note(Priority.Warning, "Note 2"),
        ],
      ),
      new Item(toCheck: "Item 5"),
      new Item(
        toCheck: "Item 6",
        notes: [new Note(Priority.Caution, "Note 3")],
      ),
    ],
    nextPrimary: list2,
    nextAlternatives: [list3],
  );

  Checklist list4 = new Checklist(name: "Emergency 1", id: "ListId4", source: [
    new Item(toCheck: "Item 11"),
    new Item(toCheck: "Item 12"),
  ]);

  return new Book(
    name: "My fancy new book",
    normalLists: [
      list1,
      list2,
      list3,
    ],
    emergencyLists: [
      list4,
    ],
    id: 'MyContainer123',
  );
}

const String serializedString = """{
      "name":"My fancy new book",
      "id":"MyContainer123",
      "normalLists":[
        {
          "name":"Normal 1",
          "id":"ListId1",
          "nextPrimary":"ListId2",
          "nextAlternatives":[
            "ListId3"
          ],
          "items":[
            {
              "toCheck":"Item 1",
              "action":"Verified",
              "notes":[
                {
                  "priority":"Priority.Note",
                  "text":"Note 1"
                },
                {
                  "priority":"Priority.Warning",
                  "text":"Note 2"
                }
              ],
              "trueBranch":[
                {
                  "toCheck":"Item 2",
                  "action":"",
                  "notes":[
                    {
                      "priority":"Priority.Note",
                      "text":"Note 1"
                    }
                  ],
                  "trueBranch":[],
                  "falseBranch":[]
                },
                {
                  "toCheck":"Item 3",
                  "action":"",
                  "notes":[],
                  "trueBranch":[],
                  "falseBranch":[]
                }
              ],
              "falseBranch":[
                {
                  "toCheck":"Item 4",
                  "action":"",
                  "notes":[],
                  "trueBranch":[],
                  "falseBranch":[]
                }
              ]
            },
            {
              "toCheck":"Item 5",
              "action":"",
              "notes":[],
              "trueBranch":[],
              "falseBranch":[]
            },
            {
              "toCheck":"Item 6",
              "action":"",
              "notes":[
                {
                  "priority":"Priority.Caution",
                  "text":"Note 3"
                }
              ],
              "trueBranch":[],
              "falseBranch":[]
            }
          ]
        },
        {
          "name":"Normal 2",
          "id":"ListId2",
          "nextPrimary":null,
          "nextAlternatives":[],
          "items":[
            {
              "toCheck":"Item 7",
              "action":"",
              "notes":[],
              "trueBranch":[],
              "falseBranch":[]
            },
            {
              "toCheck":"Item 8",
              "action":"",
              "notes":[],
              "trueBranch":[],
              "falseBranch":[]
            }
          ]
        },
        {
          "name":"Normal 3",
          "id":"ListId3",
          "nextPrimary":null,
          "nextAlternatives":[],
          "items":[
            {
              "toCheck":"Item 9",
              "action":"",
              "notes":[],
              "trueBranch":[],
              "falseBranch":[]
            },
            {
              "toCheck":"Item 10",
              "action":"",
              "notes":[],
              "trueBranch":[],
              "falseBranch":[]
            }
          ]
        }
      ],
      "emergencyLists":[
        {
          "name":"Emergency 1",
          "id":"ListId4",
          "nextPrimary":null,
          "nextAlternatives":[],
          "items":[
            {
              "toCheck":"Item 11",
              "action":"",
              "notes":[],
              "trueBranch":[],
              "falseBranch":[]
            },
            {
              "toCheck":"Item 12",
              "action":"",
              "notes":[],
              "trueBranch":[],
              "falseBranch":[]
            }
          ]
        }
      ]
    }
    """;
