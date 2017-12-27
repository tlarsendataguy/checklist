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
}
