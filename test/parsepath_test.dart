import 'dart:async';
import 'dart:io';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/bookio.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/item.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:test/test.dart';

const String bookId = "1234567890abcd";
const String bookPath = "/$bookId";
const String listId = "1111111111aaaa";
const String listPath = "$bookPath/normal/$listId";

main() {
  ParsePath.mock = true;

  setUp(() async => await createBook());

  tearDown(() async => deleteBook());

  test("Parse book path", () async {
    Book book = await ParsePath.parseBook(bookPath);
    expect(book.name, equals("My book"));
    expect(book.id, equals(bookId));
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
    expect(list.id, equals(listId));
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
    expect(book.id, equals(bookId));
  });

  test(
      "Parse book path cannot specify both normal/emergency lists and a list ID",
      () {
    expect(
      () async => await ParsePath.parseBook("$bookPath/normal/$listId"),
      throwsA(new isInstanceOf<ArgumentError>()),
    );
  });

  test("Parse path to true branch of item",() async {
    Item item = (await ParsePath.parseItem("$listPath/0/true")).item;
    expect(item.toCheck,equals("What to check"));
    expect(item.action, equals("Looks ok"));
  });
}

Future createBook() async {
  var io = new BookIo(writer: new MockDiskWriter());
  var book = new Book(
    "My book",
    id: bookId,
    normalLists: [
      new Checklist(
        "My checklist",
        id: listId,
        source: [
          new Item(
            "What to check",
            action: "Looks ok",
            trueBranch: [
              new Item(
                "True!",
                trueBranch: [new Item("Nested true!")],
              ),
            ],
            falseBranch: [
              new Item("False!"),
            ],
          )
        ],
      ),
    ],
  );
  await io.persistBook(book);
}

Future deleteBook() async {
  var file = new File("$bookId.json");
  await file.delete();
  file = new File("books.json");
  await file.delete();
}
