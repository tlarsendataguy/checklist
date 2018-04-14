import 'dart:async';
import 'dart:io';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/bookio.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/item.dart';
import 'package:checklist/src/note.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:test/test.dart';

const String bid = "1234567890abcd";
const String bookPath = "/$bid";
const String lid = "1111111111aaaa";
const String listPath = "$bookPath/normal/$lid";

main() {
  test("Paths validate correctly", () {
    var paths = {
      "/": ParseResult.Home,
      "/newBook": ParseResult.NewBook,
      "/$bid": ParseResult.Book,
      "/$bid/normal": ParseResult.NormalLists,
      "/$bid/emergency": ParseResult.EmergencyLists,
      "/$bid/normal/$lid": ParseResult.List,
      "/$bid/emergency/$lid": ParseResult.List,
      "/$bid/normal/$lid/alternatives": ParseResult.Alternatives,
      "/$bid/emergency/$lid/alternatives": ParseResult.Alternatives,
      "/$bid/normal/$lid/items": ParseResult.Items,
      "/$bid/emergency/$lid/items": ParseResult.Items,
      "/$bid/normal/$lid/items/0": ParseResult.Item,
      "/$bid/emergency/$lid/items/0": ParseResult.Item,
      "/$bid/normal/$lid/items/0/notes": ParseResult.Notes,
      "/$bid/emergency/$lid/items/0/notes": ParseResult.Notes,
      "/$bid/normal/$lid/items/0/notes/0": ParseResult.Note,
      "/$bid/emergency/$lid/items/0/notes/0": ParseResult.Note,
      "/$bid/normal/$lid/items/0/true": ParseResult.TrueBranch,
      "/$bid/emergency/$lid/items/0/true": ParseResult.TrueBranch,
      "/$bid/normal/$lid/items/0/false": ParseResult.FalseBranch,
      "/$bid/emergency/$lid/items/0/false": ParseResult.FalseBranch,
      "/$bid/normal/$lid/items/0/true/0": ParseResult.Item,
      "/$bid/emergency/$lid/items/0/true/0": ParseResult.Item,
      "/$bid/normal/$lid/items/0/false/0": ParseResult.Item,
      "/$bid/emergency/$lid/items/0/false/0": ParseResult.Item,
      "/$bid/normal/$lid/items/0/true/0/notes": ParseResult.Notes,
      "/$bid/emergency/$lid/items/0/true/0/notes": ParseResult.Notes,
      "/$bid/normal/$lid/items/0/false/0/notes": ParseResult.Notes,
      "/$bid/emergency/$lid/items/0/false/0/notes": ParseResult.Notes,
      "/$bid/normal/$lid/items/0/true/0/notes/0": ParseResult.Note,
      "/$bid/emergency/$lid/items/0/true/0/notes/0": ParseResult.Note,
      "/$bid/normal/$lid/items/0/false/0/notes/0": ParseResult.Note,
      "/$bid/emergency/$lid/items/0/false/0/notes/0": ParseResult.Note,
      "/$bid/normal/$lid/items/0/true/0/true": ParseResult.TrueBranch,
      "/$bid/emergency/$lid/items/0/true/0/false": ParseResult.FalseBranch,
      "/$bid/normal/$lid/items/0/false/0/true": ParseResult.TrueBranch,
      "/$bid/emergency/$lid/items/0/false/0/false": ParseResult.FalseBranch,
      "$bid": ParseResult.InvalidPath,
      "/$bid/normal/$lid/items/0/notes/0/false": ParseResult.InvalidPath,
      "/$bid/$lid": ParseResult.InvalidPath,
      "/1/normal/6": ParseResult.InvalidPath,
      "/$bid/normal/$lid/0": ParseResult.InvalidPath,
      "/$bid/normal/$lid/item/0": ParseResult.InvalidPath,
      "/$bid/normal/$lid/items/false": ParseResult.InvalidPath,
      "/$bid/normal/$lid/alternatives/0": ParseResult.InvalidPath,
      "/newBook/normal": ParseResult.InvalidPath,
      "/newBook/0": ParseResult.InvalidPath,
      "/newBook/$lid": ParseResult.InvalidPath,

      "/$bid/use": ParseResult.UseBook,
      "/$bid/use/0": ParseResult.InvalidPath,
    };

    for (var path in paths.keys) {
      var result = ParsePath.validate(path);
      expect(result, equals(paths[path]), reason: "Path: $path");
    }
  });

  ParsePath.setWriter(new MockDiskWriter());

  setUp(() async => await createBook());

  tearDown(() async => deleteBook());

  test("Parse newBook", () async {
    ParsedItems result = await ParsePath.parse("/newBook");
    expect(result.result, equals(ParseResult.NewBook));

    expect(result.book, isNull);
    expect(result.list, isNull);
    expect(result.item, isNull);
    expect(result.note, isNull);
  });

  test("Parse book", () async {
    ParsedItems result = await ParsePath.parse(bookPath);
    expect(result.result, equals(ParseResult.Book));

    var book = result.book;
    expect(book.name, equals("My book"));
    expect(book.id, equals(bid));
    expect(result.list, isNull);
    expect(result.item, isNull);
    expect(result.note, isNull);
  });

  test("Parse invalid book", () async {
    ParsedItems result = await ParsePath.parse("/dfl3k4J9");
    expect(result.book, isNull);
    expect(result.result, equals(ParseResult.InvalidPath));
  });

  test("Parse valid book path but no book exists", () {
    expect(
      () async => await ParsePath.parse("/9876543210abcd"),
      throwsA(new isInstanceOf<FileSystemException>()),
    );
  });

  test("Parse checklist", () async {
    ParsedItems result = await ParsePath.parse(listPath);
    expect(result.result, equals(ParseResult.List));

    Checklist list = result.list;
    expect(list.name, equals("My checklist"));
    expect(list.id, equals(lid));
    expect(result.book, isNotNull);
    expect(result.item, isNull);
    expect(result.note, isNull);
  });

  test("Parse checklist that does not exist in the book", () async {
    expect(
      () async => await ParsePath.parse("$bookPath/normal/2222222222bbbb"),
      throwsA(new isInstanceOf<ArgumentError>()),
    );
  });

  test("Parse to checklist alternatives", () async {
    ParsedItems result = await ParsePath.parse("$listPath/alternatives");
    expect(result.result, equals(ParseResult.Alternatives));

    Checklist list = result.list;
    expect(list.name, equals("My checklist"));
    expect(list.id, equals(lid));
  });

  test("Parse item", () async {
    ParsedItems result = await ParsePath.parse("$listPath/items/0");
    expect(result.result, equals(ParseResult.Item));

    Item item = result.item;
    expect(item.toCheck, equals("What to check"));
    expect(item.action, equals("Looks ok"));
    expect(result.book, isNotNull);
    expect(result.list, isNotNull);
    expect(result.note, isNull);
  });

  test("Parse nested items", () async {
    Item item = (await ParsePath.parse("$listPath/items/0/true/0")).item;
    expect(item.toCheck, equals("True!"));

    item = (await ParsePath.parse("$listPath/items/0/false/0")).item;
    expect(item.toCheck, equals("False!"));
  });

  test("Parse item that is not in the book", () async {
    expect(
      () async => await ParsePath.parse("$listPath/items/1"),
      throwsA(new isInstanceOf<ArgumentError>()),
    );
  });

  test("Parse double nested items", () async {
    Item item = (await ParsePath.parse("$listPath/items/0/true/0/true/0")).item;
    expect(item.toCheck, equals("Nested true!"));
  });

  test("Parse path to normal lists of book", () async {
    ParsedItems result = await ParsePath.parse("$bookPath/normal");
    expect(result.result, equals(ParseResult.NormalLists));

    var book = result.book;
    expect(book.name, equals("My book"));
    expect(book.id, equals(bid));
  });

  test("Parse path to true branch of item", () async {
    ParsedItems result = await ParsePath.parse("$listPath/items/0/true");
    expect(result.result, equals(ParseResult.TrueBranch));

    Item item = result.item;
    expect(item.toCheck, equals("What to check"));
    expect(item.action, equals("Looks ok"));
  });

  test("Parse path to false branch of item", () async {
    ParsedItems result = await ParsePath.parse("$listPath/items/0/false");
    expect(result.result, equals(ParseResult.FalseBranch));

    Item item = result.item;
    expect(item.toCheck, equals("What to check"));
    expect(item.action, equals("Looks ok"));
  });

  test("Parse path to notes collection of item", () async {
    ParsedItems result = await ParsePath.parse("$listPath/items/0/notes");
    expect(result.result, equals(ParseResult.Notes));

    Item item = result.item;
    expect(item.toCheck, equals("What to check"));
    expect(item.action, equals("Looks ok"));
  });

  test("Parse note", () async {
    ParsedItems result = await ParsePath.parse("$listPath/items/0/notes/0");
    expect(result.result, equals(ParseResult.Note));

    Note note = result.note;
    expect(note.priority, equals(Priority.Note));
    expect(note.text, equals("Just a simple note"));
    expect(result.book, isNotNull);
    expect(result.list, isNotNull);
    expect(result.item, isNotNull);
  });

  test("Pop path", () {
    var start = "/$bid/normal";
    var end = ParsePath.pop(start);
    expect(end, equals("/$bid"));
  });

  test("Pop path to home", () {
    var start = "/$bid";
    var end = ParsePath.pop(start);
    expect(end, equals("/"));
  });

  test("Pop invalid path", () {
    var start = "/$bid/lgj34o9jdlfkjg2094jgfdfl";
    expect(
      () => ParsePath.pop(start),
      throwsA(new isInstanceOf<ArgumentError>()),
    );
  });

  test("Parse use book", () async {
    ParsedItems result = await ParsePath.parse("/$bid/use");
    expect(result.result, equals(ParseResult.UseBook));
    expect(result.book.id, equals(bid));
  });

  test("Pop from use", (){
    var start = "/$bid/use";
    var end = ParsePath.pop(start);
    expect(end, equals('/'));
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
            notes: [
              new Note(Priority.Note, "Just a simple note"),
            ],
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
