import 'dart:async';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/bookio.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/item.dart';
import 'package:commandlist/commandlist.dart';

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

    Iterable<Checklist> collection;
    List<String> elements = path.split('/');
    String bookId = elements[1];
    String listType = elements[2];
    String listId = elements[3];

    Book book = await _getIo().readBook(bookId);
    if (listType == 'normal')
      collection = book.normalLists;
    else
      collection = book.emergencyLists;

    for (var list in collection) {
      if (list.id == listId) return list;
    }

    throw new ArgumentError(
        "The Book object does not contain the specified checklist ID");
  }

  static Future<Item> parseItem(String path) async {
    if (!_isItem(path))
      throw new ArgumentError("Path does not represent an Item object");

    List<String> elements = path.split('/');
    var listPath = elements.sublist(0, 4).join('/');
    Checklist list = await parseList(listPath);

    int index = int.parse(elements[4]);
    Item item = list[index];
    String branch;
    CommandList<Item> items;

    try {
      for (int i = 5; i < elements.length; i++) {
        if (i.isOdd){
          branch = elements[i];
          if (branch == 'true')
            items = item.trueBranch;
          else
            items = item.falseBranch;
        } else {
          index = int.parse(elements[i]);
          item = items[index];
        }
      }
      return item;
    } catch (ex) {
      throw new ArgumentError("The path does not lead to a valid item");
    }
  }

  static bool _isItem(String path) {
    List<String> nodes = path.split('/');
    if (nodes.length < 5) return false;

    bool isBook = _isList(nodes.sublist(0, 4).join('/'));

    for (var index = 4; index < nodes.length; index = index + 2) {
      isBook = isBook && stringIsIndex(nodes[index]);
    }

    for (var index = 5; index < nodes.length; index = index + 2) {
      isBook = isBook && stringIsBranch(nodes[index]);
    }

    return isBook;
  }

  static bool _isList(String path) {
    List<String> nodes = path.split('/');
    if (nodes.length < 4 || nodes.length > 5) return false;

    bool isBook = _isBook(nodes.sublist(0, 3).join('/'));

    isBook = isBook && stringIsId(nodes[3]);
    if (nodes.length == 5) isBook = isBook && stringIsBranch(nodes[4]);

    return isBook;
  }

  static bool _isBook(String path) {
    List<String> nodes = path.split('/');
    bool isBook = _startsWithSlash(path);

    if (nodes.length < 2 || nodes.length > 3) return false;

    isBook = isBook && stringIsId(nodes[1]);
    if (nodes.length == 3) isBook = isBook && stringIsListType(nodes[2]);

    return isBook;
  }

  static bool _startsWithSlash(String path) {
    return path.startsWith('/');
  }

  static bool stringIsIndex(String check) {
    return check.contains(new RegExp(r"^[0-9]+$"));
  }

  static bool stringIsListType(String check) {
    return check.contains(new RegExp(r"^(normal|emergency)$"));
  }

  static bool stringIsBranch(String check) {
    return check.contains(new RegExp(r"^(true|false)$"));
  }

  static bool stringIsId(String check) {
    return check.contains(new RegExp(r"^[0-9a-f]{14}$"));
  }

  static BookIo _getIo() {
    return mock ? new BookIo(writer: new MockDiskWriter()) : new BookIo();
  }
}
