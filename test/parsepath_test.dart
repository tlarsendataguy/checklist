import 'dart:async';
import 'dart:io';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/bookio.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/item.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:test/test.dart';

const String bid = "1234567890abcd";
const String bookPath = "/$bid";
const String lid = "1111111111aaaa";
const String listPath = "$bookPath/normal/$lid";

main() {
  test("Paths validate correctly", () {
    var paths = {
      "/": ParsePathResult.Home,
      "/newBook": ParsePathResult.NewBook,
      "/$bid": ParsePathResult.Book,
      "/$bid/normal": ParsePathResult.NormalLists,
      "/$bid/emergency": ParsePathResult.EmergencyLists,
      "/$bid/normal/$lid": ParsePathResult.List,
      "/$bid/emergency/$lid": ParsePathResult.List,
      "/$bid/normal/$lid/alternatives": ParsePathResult.Alternatives,
      "/$bid/emergency/$lid/alternatives": ParsePathResult.Alternatives,
      "/$bid/normal/$lid/items": ParsePathResult.Items,
      "/$bid/emergency/$lid/items": ParsePathResult.Items,
      "/$bid/normal/$lid/items/0": ParsePathResult.Item,
      "/$bid/emergency/$lid/items/0": ParsePathResult.Item,
      "/$bid/normal/$lid/items/0/notes": ParsePathResult.Notes,
      "/$bid/emergency/$lid/items/0/notes": ParsePathResult.Notes,
      "/$bid/normal/$lid/items/0/notes/0": ParsePathResult.Note,
      "/$bid/emergency/$lid/items/0/notes/0": ParsePathResult.Note,
      "/$bid/normal/$lid/items/0/true": ParsePathResult.TrueBranch,
      "/$bid/emergency/$lid/items/0/true": ParsePathResult.TrueBranch,
      "/$bid/normal/$lid/items/0/false": ParsePathResult.FalseBranch,
      "/$bid/emergency/$lid/items/0/false": ParsePathResult.FalseBranch,
      "/$bid/normal/$lid/items/0/true/0": ParsePathResult.Item,
      "/$bid/emergency/$lid/items/0/true/0": ParsePathResult.Item,
      "/$bid/normal/$lid/items/0/false/0": ParsePathResult.Item,
      "/$bid/emergency/$lid/items/0/false/0": ParsePathResult.Item,
      "/$bid/normal/$lid/items/0/true/0/notes": ParsePathResult.Notes,
      "/$bid/emergency/$lid/items/0/true/0/notes": ParsePathResult.Notes,
      "/$bid/normal/$lid/items/0/false/0/notes": ParsePathResult.Notes,
      "/$bid/emergency/$lid/items/0/false/0/notes": ParsePathResult.Notes,
      "/$bid/normal/$lid/items/0/true/0/notes/0": ParsePathResult.Note,
      "/$bid/emergency/$lid/items/0/true/0/notes/0": ParsePathResult.Note,
      "/$bid/normal/$lid/items/0/false/0/notes/0": ParsePathResult.Note,
      "/$bid/emergency/$lid/items/0/false/0/notes/0": ParsePathResult.Note,
      "/$bid/normal/$lid/items/0/true/0/true": ParsePathResult.TrueBranch,
      "/$bid/emergency/$lid/items/0/true/0/false": ParsePathResult.FalseBranch,
      "/$bid/normal/$lid/items/0/false/0/true": ParsePathResult.TrueBranch,
      "/$bid/emergency/$lid/items/0/false/0/false": ParsePathResult.FalseBranch,
      "$bid": ParsePathResult.InvalidPath,
      "/$bid/normal/$lid/items/0/notes/0/false": ParsePathResult.InvalidPath,
      "/$bid/$lid": ParsePathResult.InvalidPath,
      "/1/normal/6": ParsePathResult.InvalidPath,
      "/$bid/normal/$lid/0": ParsePathResult.InvalidPath,
      "/$bid/normal/$lid/item/0": ParsePathResult.InvalidPath,
      "/$bid/normal/$lid/items/false": ParsePathResult.InvalidPath,
      "/$bid/normal/$lid/alternatives/0": ParsePathResult.InvalidPath,
      "/newBook/normal": ParsePathResult.InvalidPath,
      "/newBook/0": ParsePathResult.InvalidPath,
      "/newBook/$lid": ParsePathResult.InvalidPath,
    };

    for (var path in paths.keys){
      var result = ParsePath.validatePath(path);
      expect(result, equals(paths[path]),reason: "Path: $path");
    }
  });

  ParsePath.mock = true;

  setUp(() async => await createBook());

  tearDown(() async => deleteBook());

  test("Parse book path", () async {
    Book book = await ParsePath.parseBook(bookPath);
    expect(book.name, equals("My book"));
    expect(book.id, equals(book));
  });

  test("Parse invalid book path", () async {
    expect(
      () async => await ParsePath.parseBook("/dfl3k4J9"),
      throwsA(new isInstanceOf<ArgumentError>()),
    );
  });

  test("Parse valid book path but no book exists", () {
    expect(
      () async => await ParsePath.parseBook("/9876543210abcd"),
      throwsA(new isInstanceOf<FileSystemException>()),
    );
  });

  test("Parse checklist path", () async {
    ChecklistWithParent parent = await ParsePath.parseList(listPath);
    Checklist list = parent.list;
    expect(list.name, equals("My checklist"));
    expect(list.id, equals(list));
  });

  test("Parse checklist that does not exist in the book", () async {
    expect(
      () async => await ParsePath.parseList("$bookPath/2222222222bbbb"),
      throwsA(new isInstanceOf<ArgumentError>()),
    );
  });

  test("Parse item", () async {
    Item item = (await ParsePath.parseItem("$listPath/0")).item;
    expect(item.toCheck, equals("What to check"));
    expect(item.action, equals("Looks ok"));
  });

  test("Parse nested items", () async {
    Item item = (await ParsePath.parseItem("$listPath/0/true/0")).item;
    expect(item.toCheck, equals("True!"));

    item = (await ParsePath.parseItem("$listPath/0/false/0")).item;
    expect(item.toCheck, equals("False!"));
  });

  test("Parse item that is not in the book", () async {
    expect(
      () async => await ParsePath.parseItem("$listPath/1"),
      throwsA(new isInstanceOf<ArgumentError>()),
    );
  });

  test("Parse double nested items", () async {
    Item item = (await ParsePath.parseItem("$listPath/0/true/0/true/0")).item;
    expect(item.toCheck, equals("Nested true!"));
  });

  test("Parse path to normal lists of book", () async {
    var book = await ParsePath.parseBook("$bookPath/normal");
    expect(book.name, equals("My book"));
    expect(book.id, equals(book));
  });

  test(
      "Parse book path cannot specify both normal/emergency lists and a list ID",
      () {
    expect(
      () async => await ParsePath.parseBook("$bookPath/normal/$lid"),
      throwsA(new isInstanceOf<ArgumentError>()),
    );
  });

  test("Parse path to true branch of item", () async {
    Item item = (await ParsePath.parseItem("$listPath/0/true")).item;
    expect(item.toCheck, equals("What to check"));
    expect(item.action, equals("Looks ok"));
  });
}

Future createBook() async {
  var io = new BookIo(writer: new MockDiskWriter());
  var book = new Book(
    name: "My book",
    id: bid,
    normalLists: [
      new Checklist(
        name: "My checklist",
        id: lid,
        source: [
          new Item(
            toCheck: "What to check",
            action: "Looks ok",
            trueBranch: [
              new Item(
                toCheck: "True!",
                trueBranch: [new Item(toCheck: "Nested true!")],
              ),
            ],
            falseBranch: [
              new Item(toCheck: "False!"),
            ],
          )
        ],
      ),
    ],
  );
  await io.persistBook(book);
}

Future deleteBook() async {
  var file = new File("$bid.json");
  await file.delete();
  file = new File("books.json");
  await file.delete();
}
