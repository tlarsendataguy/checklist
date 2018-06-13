import 'dart:async';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/bookio.dart';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/diskwriter.dart';
import 'package:checklist/src/item.dart';
import 'package:checklist/src/note.dart';
import 'package:commandlist/commandlist.dart';

// Paths must be of the following formats:
// /newBook
// /bookId/(normal|emergency)/listId/items/index/(true|false/index)*/notes/index
// /bookId/(normal|emergency)/listId/alternatives

enum ParseResult {
  InvalidPath,
  Home,
  NewBook,
  UseBook,
  Book,
  NormalLists,
  EmergencyLists,
  List,
  Alternatives,
  Items,
  Item,
  TrueBranch,
  FalseBranch,
  Notes,
  Note,
}

class ParsePath {
  static DiskWriter _writer;

  static void setWriter(DiskWriter writer) {
    _writer = writer;
  }

  static ParseResult validate(String path) {
    var elements = path.split('/');

    return _validateHome(elements);
  }

  static ParseResult _validateHome(List<String> elements) {
    // Paths must start with /
    if (elements.length < 2 || elements[0].isNotEmpty)
      return ParseResult.InvalidPath;

    if (elements[1].isEmpty && elements.length == 2)
      return ParseResult.Home;

    return _validateBook(elements);
  }

  static ParseResult _validateBook(List<String> elements) {
    if (!_isId(elements[1]) && elements[1] != 'newBook')
      return ParseResult.InvalidPath;

    if (elements[1] == 'newBook') {
      if (elements.length > 2) return ParseResult.InvalidPath;

      return ParseResult.NewBook;
    }

    if (elements.length == 3 && elements[2] == 'use') {
      return ParseResult.UseBook;
    }

    if (elements.length == 2) return ParseResult.Book;

    return _validateBookColl(elements);
  }

  static ParseResult _validateBookColl(List<String> elements) {
    if (!_isBookColl(elements[2])) return ParseResult.InvalidPath;

    if (elements.length == 3) {
      switch (elements[2]) {
        case 'normal':
          return ParseResult.NormalLists;
        case 'emergency':
          return ParseResult.EmergencyLists;
      }
    }

    return _validateList(elements);
  }

  static ParseResult _validateList(List<String> elements) {
    if (!_isId(elements[3])) return ParseResult.InvalidPath;

    if (elements.length == 4) return ParseResult.List;

    return _validateListColl(elements);
  }

  static ParseResult _validateListColl(List<String> elements) {
    if (!_isListColl(elements[4])) return ParseResult.InvalidPath;

    if (elements.length == 5) {
      switch (elements[4]) {
        case 'items':
          return ParseResult.Items;
        case 'alternatives':
          return ParseResult.Alternatives;
      }
    } else if (elements[4] == 'alternatives')
      return ParseResult.InvalidPath;

    return _validateItem(elements, 5);
  }

  static ParseResult _validateItem(List<String> elements, int current) {
    if (!_isIndex(elements[current])) return ParseResult.InvalidPath;

    if (elements.length == current + 1) return ParseResult.Item;

    current++;
    if (!_isItemColl(elements[current])) return ParseResult.InvalidPath;

    if (elements.length == current + 1) {
      switch (elements[current]) {
        case 'notes':
          return ParseResult.Notes;
        case 'true':
          return ParseResult.TrueBranch;
        case 'false':
          return ParseResult.FalseBranch;
      }
    }

    if (elements[current] == 'notes') {
      current++;
      if (!_isIndex(elements[current])) return ParseResult.InvalidPath;

      if (elements.length > current + 1) return ParseResult.InvalidPath;

      return ParseResult.Note;
    }

    current++;
    return _validateItem(elements, current);
  }

  static Future<ParsedItems> parse(String path) async {
    if (_writer == null){
      throw new Exception("writer was not set before calling parse");
    }

    var result = validate(path);
    if (result.index <= ParseResult.NewBook.index)
      return new ParsedItems(result: result);

    var elements = path.split('/');
    var book = await _getIo(_writer).readBook(elements[1]);

    CommandList<Checklist> listColl;
    if (result.index >= ParseResult.NormalLists.index)
      listColl = _parseListColl(book,path);

    Checklist list;
    if (result.index >= ParseResult.List.index)
      list = _parseList(listColl, path);

    _ParsedItem item;
    if (result.index >= ParseResult.Item.index)
      item = _parseItem(list, path, 5);

    Note note;
    if (result.index >= ParseResult.Note.index)
      note = _parseNote(item.item, path);

    return new ParsedItems(
      book: book,
      listColl: listColl,
      list: list,
      itemColl: item?.parentCollection,
      item: item?.item,
      note: note,
      result: result,
    );
  }

  static CommandList<Checklist> _parseListColl(Book book, String path) {
    List<String> elements = path.split('/');
    String listType = elements[2];

    if (listType == 'normal') {
      return book.normalLists;
    } else {
      return book.emergencyLists;
    }
  }

  static Checklist _parseList(Iterable<Checklist> listColl, String path) {
    List<String> elements = path.split('/');
    String listId = elements[3];


    for (var list in listColl) {
      if (list.id == listId) return list;
    }

    throw new ArgumentError(
        "The Book object does not contain the specified checklist ID");
  }

  static _ParsedItem _parseItem(
      CommandList<Item> items, String path, int current) {
    List<String> elements = path.split('/');
    int index = int.parse(elements[current]);

    try {
      Item item = items[index];
      if (elements.length > current + 2) {
        switch (elements[current + 1]) {
          case 'true':
            return _parseItem(item.trueBranch, path, current + 2);
          case 'false':
            return _parseItem(item.falseBranch, path, current + 2);
          default:
            return new _ParsedItem(items,item);
        }
      }
      return new _ParsedItem(items,item);
    } catch (ex) {
      throw new ArgumentError("The path does not lead to a valid item");
    }
  }

  static Note _parseNote(Item item, String path) {
    var elements = path.split('/');
    var noteIndex = int.parse(elements[elements.length - 1]);
    return item.notes[noteIndex];
  }

  static String pop(String path){
    if (validate(path) == ParseResult.InvalidPath)
      throw new ArgumentError("The path provided is not a valid path");

    var elements = path.split('/');
    if (elements[elements.length - 1] == 'use') elements.removeLast();
    elements.removeLast();
    var backPath = elements.join('/');
    if (backPath == '') backPath = '/';
    return backPath;
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

  static BookIo _getIo(DiskWriter writer) {
    return new BookIo(writer: writer);
  }
}

class ParsedItems {
  ParsedItems({this.book, this.listColl, this.list, this.itemColl, this.item, this.note, this.result});

  final Book book;
  final CommandList<Checklist> listColl;
  final Checklist list;
  final CommandList<Item> itemColl;
  final Item item;
  final Note note;
  final ParseResult result;
}

class _ParsedItem {
  _ParsedItem(this.parentCollection,this.item);
  final CommandList<Item> parentCollection;
  final Item item;
}
