import 'dart:convert';
import 'package:checklist/src/checklist.dart';
import 'package:checklist/src/container.dart';
import 'package:checklist/src/item.dart';
import 'package:checklist/src/note.dart';

class Serializer {
  static String serialize(Container container) {
    return Serialize.serialize(container);
  }

  static Container deserialize(String serializedContainer) {
    var deserializer = new Deserialize();
    return deserializer.deserialize(serializedContainer);
  }
}

class Deserialize {
  var _idToList = new Map<String, Checklist>();
  var _uniqueNotes = new Map<String, Note>();
  var _nextPrimaries = new List<ChecklistMap>();
  var _nextAlternatives = new List<ChecklistMap>();

  Container deserialize(String serializedContainer) {
    _idToList.clear();
    _uniqueNotes.clear();
    _nextPrimaries.clear();
    _nextAlternatives.clear();

    try {
      Map<String, Object> map = JSON.decode(serializedContainer);
      return _deserializeContainer(serializedContainer);
    } catch (_, stacktrace) {
      throw new MalformedStringException(
        "The string does not represent a valid Container object",
        stacktrace,
      );
    }
  }

  Container _deserializeContainer(String serializedContainer) {
    Map<String, Object> map = JSON.decode(serializedContainer);
    var normalLists = _deserializeChecklistList(map['normalLists']);
    var emergencyLists = _deserializeChecklistList(map['emergencyLists']);

    for (var map in _nextPrimaries) {
      map.list.setNextPrimary(_idToList[map.mappedId]);
    }

    for (var map in _nextAlternatives) {
      map.list.nextAlternatives.insert(_idToList[map.mappedId]);
    }

    return new Container(
      map['name'],
      id: map['id'],
      normalLists: normalLists,
      emergencyLists: emergencyLists,
    );
  }

  Iterable<Checklist> _deserializeChecklistList(
      List<Map<String, Object>> lists) {
    var deserializedLists = new List<Checklist>();
    for (var list in lists) {
      deserializedLists.add(_deserializeChecklist(list));
    }
    return deserializedLists;
  }

  Checklist _deserializeChecklist(Map<String, Object> list) {
    var newList = new Checklist(
      list['name'],
      id: list['id'],
      source: _deserializeItemList(list['items']),
    );

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

  List<Item> _deserializeItemList(List<Map<String, Object>> items) {
    var deserializedItems = new List<Item>();
    for (var item in items) {
      deserializedItems.add(_deserializeItem(item));
    }
    return deserializedItems;
  }

  Item _deserializeItem(Map<String, Object> item) {
    var trueItems = new List<Item>();
    for (Map<String, Object> trueItem in item['trueBranch']) {
      trueItems.add(_deserializeItem(trueItem));
    }

    var falseItems = new List<Item>();
    for (Map<String, Object> falseItem in item['falseBranch']) {
      falseItems.add(_deserializeItem(falseItem));
    }

    var notes = new List<Note>();
    for (Map<String, String> note in item['notes']) {
      notes.add(_deserializeNote(note));
    }

    return new Item(
      item['toCheck'],
      action: item['action'],
      notes: notes,
      trueBranch: trueItems,
      falseBranch: falseItems,
    );
  }

  Note _deserializeNote(Map<String, String> note) {
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
  static String serialize(Container container) {
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
