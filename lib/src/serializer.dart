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
    return Deserialize.deserialize(serializedContainer);
  }
}

class Deserialize {
  static Container deserialize(String serializedContainer) {
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

  static Container _deserializeContainer(String serializedContainer){
    Map<String,Object> map = JSON.decode(serializedContainer);
    var normalLists = _deserializeChecklistList(map['normalLists']);
    var emergencyLists = _deserializeChecklistList(map['emergencyLists']);
    return new Container(
      map['name'],
      id: map['id'],
      normalLists: normalLists,
      emergencyLists: emergencyLists,
    );
  }

  static Iterable<Checklist> _deserializeChecklistList(List<Map<String,Object>> lists){
    var deserializedLists = new List<Checklist>();
    for (var list in lists){
      deserializedLists.add(_deserializeChecklist(list));
    }
    return deserializedLists;
  }

  static Checklist _deserializeChecklist(Map<String,Object> list){
    return new Checklist(
      list['name'],
      id: list['id'],
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
