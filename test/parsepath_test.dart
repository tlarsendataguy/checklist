import 'dart:async';
import 'dart:io';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/bookio.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:test/test.dart';

const String bookId = "1234567890abcd";
const String bookPath = "/$bookId";
const String listId = "1111111111aaaa";
const String listPath = "$bookPath/$listId";
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
    Checklist list = await ParsePath.parseList(listPath);
    expect(list.name, equals("My checklist"));
    expect(list.id, equals(listId));
  });

  test("Parse checklist that does not exist in the book",() async {
    expect(
          () async => await ParsePath.parseList("$bookPath/2222222222bbbb"),
      throwsA(new isInstanceOf<ArgumentError>()),
    );
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
