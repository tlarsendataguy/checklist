import 'package:test/test.dart';
import 'package:checklist/src/note.dart';

main() {
  test("Notes with a higher priority sort before lower priority", () {
    var note1 = new Note(Priority.Warning, "Note");
    var note2 = new Note(Priority.Note, "Note");

    expect(note1.compareTo(note2), equals(-1));
    expect(note2.compareTo(note1), equals(1));
  });

  test("Notes with the same priority sort alphabetically on text", () {
    var note1 = new Note(Priority.Note, "A");
    var note2 = new Note(Priority.Note, "B");

    expect(note1.compareTo(note2), equals(-1));
    expect(note2.compareTo(note1), equals(1));
  });

  test("Note constructor parameters cannot be null", () {
    expect(
        () => new Note(null, "A"), throwsA(new isInstanceOf<AssertionError>()));
    expect(() => new Note(Priority.Note, null),
        throwsA(new isInstanceOf<AssertionError>()));
  });

  test("Change note text", () {
    var note = new Note(Priority.Note, "Mispeled text");

    var command = note.changeText("Mispelled text");
    expect(command.key, equals("Note.ChangeText"));
    expect(note.text, equals("Mispelled text"));

    command.undo();
    expect(note.text, equals("Mispeled text"));

    command.execute();
    expect(note.text, equals("Mispelled text"));
  });

  test("Change note priority", () {
    var note = new Note(Priority.Note, "Hello world");

    var command = note.changePriority(Priority.Warning);
    expect(command.key, equals("Note.ChangePriority"));
    expect(note.priority, equals(Priority.Warning));

    command.undo();
    expect(note.priority, equals(Priority.Note));

    command.execute();
    expect(note.priority, equals(Priority.Warning));
  });

  test("Changing note text to null throws an error", () {
    var note = new Note(Priority.Note, "Well hi!");
    expect(() => note.changeText(null),
        throwsA(new isInstanceOf<AssertionError>()));
  });

  test("Changing note priority to null throws an error", () {
    var note = new Note(Priority.Note, "Hello!");
    expect(() => note.changePriority(null),
        throwsA(new isInstanceOf<AssertionError>()));
  });
}
