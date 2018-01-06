import 'dart:async';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/bookio.dart';
import 'package:checklist/src/checklist.dart';

class ParsePath {
  static bool mock = false;

  static Future<Book> parseBook(String path) async {
    if (!_isBook(path))
      throw new ArgumentError("path does not represent a Book object");

    String id = path.split('/')[1];
    return await _getIo().readBook(id);
  }

  static Future<Checklist> parseList(String path) async {
    if (!_isList(path))
      throw new ArgumentError("path does not represent a Checklist object");

    List<String> elements = path.split('/');
    String bookId = elements[1];
    String listId = elements[2];
    Book book = await _getIo().readBook(bookId);
    for (var collection in [book.normalLists, book.emergencyLists]) {
      for (var list in collection) {
        if (list.id == listId) return list;
      }
    }
    throw new ArgumentError(
        "The Book object does not contain the specified checklist ID");
  }

  static bool _isList(String path) {
    List<String> nodes = path.split('/');
    if (_startsWithSlash(path) && nodes.length == 3) {
      return _stringIsId(nodes[1]) && _stringIsId(nodes[2]);
    }
    return false;
  }

  static bool _isBook(String path) {
    List<String> nodes = path.split('/');
    if (_startsWithSlash(path) && nodes.length == 2) {
      return _stringIsId(nodes[1]);
    }
    return false;
  }

  static bool _startsWithSlash(String path) {
    return path.startsWith('/');
  }

  static bool _stringIsId(String check) {
    return check.contains(new RegExp(r"^[0-9a-f]{14}$"));
  }

  static BookIo _getIo() {
    return mock ? new BookIo(writer: new MockDiskWriter()) : new BookIo();
  }
}
