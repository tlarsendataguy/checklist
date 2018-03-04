import 'dart:convert';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/book.dart';
import 'package:checklist/src/item.dart';
import 'package:checklist/src/note.dart';

class Serializer {
  static String serialize(Book book) {
    return Serialize.serialize(book);
  }

  static Book deserialize(String serializedContainer) {
    var deserializer = new Deserialize();
    return deserializer.deserialize(serializedContainer);
  }
}

class Deserialize {
  var _idToList = new Map<String, Checklist>();
  var _uniqueNotes = new Map<String, Note>();
  var _nextPrimaries = new List<ChecklistMap>();
  var _nextAlternatives = new List<ChecklistMap>();

  Book deserialize(String serializedBook) {
    _idToList.clear();
    _uniqueNotes.clear();
    _nextPrimaries.clear();
    _nextAlternatives.clear();

    try {
      return _deserializeBook(serializedBook);
    } catch (_, stacktrace) {
      throw new MalformedStringException(
        "The string does not represent a valid Book object",
        stacktrace,
      );
    }
  }

  Book _deserializeBook(String serializedBook) {
    var map = JSON.decode(serializedBook);
    Book book = new Book(
        name: map['name'],
        id: map['id'],
    );

    _deserializeChecklistLists(map['normalLists'],map['emergencyLists'],book);

    for (var map in _nextPrimaries) {
      map.list.setNextPrimary(_idToList[map.mappedId]);
    }

    for (var map in _nextAlternatives) {
      map.list.nextAlternatives.insert(_idToList[map.mappedId]);
    }

    return book;
  }

  void _deserializeChecklistLists(
      List normalLists,
      List emergencyLists,
      Book book,
      ) {
    for (var list in normalLists) {
      book.normalLists.insert(_deserializeChecklist(list));
    }
    for (var list in emergencyLists){
      book.emergencyLists.insert(_deserializeChecklist(list));
    }
  }

  Checklist _deserializeChecklist(Map<String, Object> list) {
    var newList = new Checklist(
      name: list['name'],
      id: list['id'],
    );

    _deserializeItemList(list['items'],newList);

    if (list['nextPrimary'] != null) {
      _nextPrimaries
          .add(new ChecklistMap(newList, list['nextPrimary'].toString()));
    }

    if (list['nextAlternatives'] != null) {
      for (var alternative in list['nextAlternatives']) {
        _nextAlternatives.add(new ChecklistMap(newList, alternative));
      }
    }

    _idToList.putIfAbsent(newList.id, () => newList);
    return newList;
  }

  void _deserializeItemList(List items, Checklist parent) {
    for (var item in items) {
      parent.insert(_deserializeItem(item));
    }
  }

  Item _deserializeItem(Map<String, Object> item) {
    var newItem = new Item(
      toCheck: item['toCheck'],
      action: item['action'],
    );

    for (Map<String, Object> trueItem in item['trueBranch']) {
      newItem.trueBranch.insert(_deserializeItem(trueItem));
    }

    for (Map<String, Object> falseItem in item['falseBranch']) {
      newItem.falseBranch.insert(_deserializeItem(falseItem));
    }

    for (Map<String, Object> note in item['notes']) {
      newItem.notes.insert(_deserializeNote(note));
    }

    return newItem;
  }

  Note _deserializeNote(Map<String, Object> note) {
    return _uniqueNotes.putIfAbsent(
      "${note['priority']}.${note['text']}",
      () => new Note(
            Priority.values.firstWhere((e) => e.toString() == note['priority']),
            note['text'],
          ),
    );
  }
}

class Serialize {
  static String serialize(Book container) {
    var containerMap = <String, Object>{
      "name": container.name,
      "id": container.id,
      "normalLists": _serializeChecklistList(container.normalLists),
      "emergencyLists": _serializeChecklistList(container.emergencyLists),
    };

    return JSON.encode(containerMap);
  }

  static List<Map<String, Object>> _serializeChecklistList(
      Iterable<Checklist> lists) {
    var serializableLists = new List<Map<String, Object>>();
    for (var list in lists) {
      serializableLists.add(_serializeChecklist(list));
    }
    return serializableLists;
  }

  static Map<String, Object> _serializeChecklist(Checklist list) {
    var serializableAlternatives = new List<String>();

    for (var alternative in list.nextAlternatives) {
      serializableAlternatives.add(alternative.id);
    }

    var map = <String, Object>{
      "name": list.name,
      "id": list.id,
      "nextPrimary": list.nextPrimary?.id,
      "nextAlternatives": serializableAlternatives,
      "items": _serializeItemList(list),
    };
    return map;
  }

  static List<Map<String, Object>> _serializeItemList(Iterable<Item> items) {
    var serializeableItems = new List<Map<String, Object>>();
    for (var item in items) {
      serializeableItems.add(_serializeItem(item));
    }
    return serializeableItems;
  }

  static Map<String, Object> _serializeItem(Item item) {
    var map = <String, Object>{
      "toCheck": item.toCheck,
      "action": item.action,
      "notes": _serializeNotesList(item.notes),
      "trueBranch": _serializeItemList(item.trueBranch),
      "falseBranch": _serializeItemList(item.falseBranch),
    };
    return map;
  }

  static List<Map<String, Object>> _serializeNotesList(Iterable<Note> notes) {
    var serializeableNotes = new List<Map<String, Object>>();
    for (var note in notes) {
      serializeableNotes.add(_serializeNote(note));
    }
    return serializeableNotes;
  }

  static Map<String, Object> _serializeNote(Note note) {
    return <String, Object>{
      "priority": note.priority.toString(),
      "text": note.text,
    };
  }
}

class MalformedStringException implements Exception {
  final dynamic message;
  final dynamic stacktrace;
  MalformedStringException(this.message, this.stacktrace);

  String toString() {
    return "Instance of 'MalformedStringException': $message\nStack trace:\n$stacktrace";
  }
}

class ChecklistMap {
  final Checklist list;
  final String mappedId;
  ChecklistMap(this.list, this.mappedId);
}
