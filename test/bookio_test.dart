import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:checklist/src/diskwriter.dart';
import 'package:test/test.dart';
import 'package:checklist/src/book.dart';
import 'package:checklist/src/bookio.dart';

main() {
  test("Write book", () async {
    var io = new BookIo(writer: new MockDiskWriter());
    var book = new Book(name: "Hello!", id: "123456");
    var didSucceed = await io.persistBook(book);
    expect(didSucceed, isTrue);
    expect(io.files['123456'], equals("Hello!"));

    var file = new File("123456.json");
    expect(await file.exists(), isTrue);

    await cleanUpFiles();
  });

  test("Read book", () async {
    var io = new BookIo(writer: new MockDiskWriter());
    var book = new Book(name: "Hello!");
    var id = book.id;
    await io.persistBook(book);

    book = await io.readBook(id);
    expect(book.name, equals("Hello!"));
    expect(book.id, equals(id));

    await cleanUpFiles();
  });

  test("Ready book that does not exist", () async {
    var io = new BookIo(writer: new MockDiskWriter());
    expect(
      () async {
        await io.readBook("123456");
      },
      throwsA(new isInstanceOf<FileSystemException>()),
    );
  });

  test("Delete book", () async {
    var io = new BookIo(writer: new MockDiskWriter());
    var book = new Book(name: "Short-lived book", id: "543210");
    await io.persistBook(book);

    var file = new File("543210.json");
    expect(await file.exists(), isTrue);

    await io.deleteBook("543210");
    expect(await file.exists(), isFalse);
    expect(io.files.length, equals(0));

    await cleanUpFiles();
  });

  test("Delete book that does not exist", () async {
    var io = new BookIo(writer: new MockDiskWriter());
    expect(
      () async {
        await io.deleteBook("9349823");
      },
      throwsA(new isInstanceOf<FileSystemException>()),
    );
  });
}

Future cleanUpFiles() async {
  var file = new File("books.json");
  Map<String, Object> filesToDelete = json.decode(await file.readAsString());
  await file.delete();
  for (var fileToDelete in filesToDelete.keys) {
    file = new File("$fileToDelete.json");
    await file.delete();
  }
}
