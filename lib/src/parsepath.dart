import 'dart:async';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/bookio.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/item.dart';
import 'package:commandlist/commandlist.dart';
import 'package:meta/meta.dart';


// Paths must be of the following formats:
// /newBook
// /bookId/(normal|emergency)/listId/items/index/(true|false/index)*/notes/index
// /bookId/(normal|emergency)/listId/alternatives
//
// The return object should contains the following references:
//   Book
//   List of checklists
//   List
//   List of alternatives
//   List of items
//   Item
//   List of sub-items
//   List of notes
//   Note
//
// An enum describing the final object in the path should also be contained:
//   Home
//   Book
//   NormalLists
//   EmergencyLists
//   List
//   Items
//   Alternatives
//   Item
//   TrueBranch
//   FalseBranch
//   Notes
//   Note
//   InvalidPath
//
// Provide a method to check syntax which returns the enum
// Provide a second method to actually perform the parse

enum ParsePathResult{
  Home,
  NewBook,
  Book,
  NormalLists,
  EmergencyLists,
  List,
  Items,
  Alternatives,
  Item,
  TrueBranch,
  FalseBranch,
  Notes,
  Note,
  InvalidPath,
}

class ParsePath {
  static bool mock = false;

  static ParsePathResult validatePath(String path){
    var elements = path.split('/');

    return _validateHome(elements);
  }

  static ParsePathResult _validateHome(List<String> elements) {
    // Paths must start with /
    if (elements.length < 2 || elements[0].isNotEmpty)
      return ParsePathResult.InvalidPath;

    if (elements[1].isEmpty && elements.length == 2)
      return ParsePathResult.Home;

    return _validateBook(elements);
  }

  static ParsePathResult _validateBook(List<String> elements) {
    if (!_isId(elements[1]) && elements[1] != 'newBook')
      return ParsePathResult.InvalidPath;

    if (elements[1] == 'newBook'){
      if (elements.length > 2)
        return ParsePathResult.InvalidPath;

      return ParsePathResult.NewBook;
    }

    if (elements.length == 2)
      return ParsePathResult.Book;

    return _validateBookColl(elements);
  }

  static ParsePathResult _validateBookColl(List<String> elements) {
    if (!_isBookColl(elements[2]))
      return ParsePathResult.InvalidPath;

    if (elements.length == 3){
      switch (elements[2]){
        case 'normal':
          return ParsePathResult.NormalLists;
        case 'emergency':
          return ParsePathResult.EmergencyLists;
      }
    }

    return _validateList(elements);
  }

  static ParsePathResult _validateList(List<String> elements) {
    if (!_isId(elements[3]))
      return ParsePathResult.InvalidPath;

    if (elements.length == 4)
      return ParsePathResult.List;

    return _validateListColl(elements);
  }

  static ParsePathResult _validateListColl(List<String> elements) {
    if (!_isListColl(elements[4]))
      return ParsePathResult.InvalidPath;

    if (elements.length == 5){
      switch (elements[4]){
        case 'items':
          return ParsePathResult.Items;
        case 'alternatives':
          return ParsePathResult.Alternatives;
      }
    } else if (elements[4] == 'alternatives')
      return ParsePathResult.InvalidPath;

    return _validateItem(elements,5);
  }

  static ParsePathResult _validateItem(List<String> elements, int current){
    if (!_isIndex(elements[current]))
      return ParsePathResult.InvalidPath;

    if (elements.length == current + 1)
      return ParsePathResult.Item;

    current++;
    if (!_isItemColl(elements[current]))
      return ParsePathResult.InvalidPath;

    if (elements.length == current + 1){
      switch (elements[current]){
        case 'notes':
          return ParsePathResult.Notes;
        case 'true':
          return ParsePathResult.TrueBranch;
        case 'false':
          return ParsePathResult.FalseBranch;
      }
    }

    if (elements[current] == 'notes'){
      current++;
      if (!_isIndex(elements[current]))
        return ParsePathResult.InvalidPath;

      if (elements.length > current + 1)
        return ParsePathResult.InvalidPath;

      return ParsePathResult.Note;
    }

    current++;
    return _validateItem(elements, current);
  }

  static Future<Book> parseBook(String path) async {
    if (!_isBook(path))
      throw new ArgumentError("path does not represent a Book object");

    String id = path.split('/')[1];
    return await _getIo().readBook(id);
  }

  static Future<ChecklistWithParent> parseList(String path) async {
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
      if (list.id == listId)
        return new ChecklistWithParent(list: list, parent: book);
    }

    throw new ArgumentError(
        "The Book object does not contain the specified checklist ID");
  }

  static Future<ItemWithParent> parseItem(String path,{Book outBook}) async {
    if (!_isItem(path))
      throw new ArgumentError("Path does not represent an Item object");

    List<String> elements = path.split('/');
    var listPath = elements.sublist(0, 4).join('/');
    ChecklistWithParent parent = await parseList(listPath);
    Checklist list = parent.list;

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
      return new ItemWithParent(item: item, parent: parent);
    } catch (ex) {
      throw new ArgumentError("The path does not lead to a valid item");
    }
  }

  static bool _isItem(String path) {
    List<String> nodes = path.split('/');
    if (nodes.length < 5) return false;

    bool isBook = _isList(nodes.sublist(0, 4).join('/'));

    for (var index = 4; index < nodes.length; index = index + 2) {
      isBook = isBook && _isIndex(nodes[index]);
    }

    for (var index = 5; index < nodes.length; index = index + 2) {
      isBook = isBook && _isItemColl(nodes[index]);
    }

    return isBook;
  }

  static bool _isList(String path) {
    List<String> nodes = path.split('/');
    if (nodes.length < 4 || nodes.length > 5) return false;

    bool isBook = _isBook(nodes.sublist(0, 3).join('/'));

    isBook = isBook && stringIsId(nodes[3]);
    if (nodes.length == 5) isBook = isBook && _isItemColl(nodes[4]);

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

  static bool _isIndex(String check) {
    return check.contains(new RegExp(r"^[0-9]+$"));
  }

  static bool _isBookColl(String check) {
    return check.contains(new RegExp(r"^(normal|emergency)$"));
  }

  static bool _isListColl(String check) {
    return check.contains(new RegExp(r"^(items|alternatives)$"));
  }

  static bool _isItemColl(String check) {
    return check.contains(new RegExp(r"^(true|false|notes)$"));
  }

  static bool _isId(String check) {
    return check.contains(new RegExp(r"^[0-9a-f]{14}$"));
  }

  static BookIo _getIo() {
    return mock ? new BookIo(writer: new MockDiskWriter()) : new BookIo();
  }
}

class ChecklistWithParent{
  final Book parent;
  final Checklist list;
  ChecklistWithParent({@required this.list, @required this.parent}) :
    assert(parent != null && list != null);
}

class ItemWithParent{
  final ChecklistWithParent parent;
  final Item item;
  ItemWithParent({@required this.item, @required this.parent}) :
      assert(item != null && parent != null);
}