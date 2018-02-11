import 'package:test/test.dart';
import 'package:checklist/src/book.dart';
import 'package:checklist/src/checklist.dart';

main() {
  test("Create a book with the specified name", () {
    var book = new Book(name: "C172 Skyhawk");
    expect(book.name, equals("C172 Skyhawk"));
    expect(book.id.length, greaterThan(0));
    expect(book.normalLists.length, equals(0));
    expect(book.emergencyLists.length, equals(0));
  });

  test("Create a book with a specified ID", () {
    var book = new Book(name: "C172 Skyhawk", id: '05a49c5890f824');
    expect(book.name, equals("C172 Skyhawk"));
    expect(book.id, equals("05a49c5890f824"));
  });

  test("Create a book with specified normal and emergency lists", () {
    var book = new Book(
      name: "C172 Skyhawk",
      normalLists: [
        new Checklist(name: "Normal 1"),
        new Checklist(name: "Normal 2"),
      ],
      emergencyLists: [
        new Checklist(name: "Emergency 1"),
        new Checklist(name: "Emergency 2"),
      ],
    );

    expect(book.normalLists.length, equals(2));
    expect(book.emergencyLists.length, equals(2));
    expect(book.normalLists[0].name, equals("Normal 1"));
    expect(book.normalLists[1].name, equals("Normal 2"));
    expect(book.emergencyLists[0].name, equals("Emergency 1"));
    expect(book.emergencyLists[1].name, equals("Emergency 2"));
  });

  test("Change book name",(){
    var book = new Book(name: "Hello");
    expect(book.name, equals("Hello"));

    var command = book.changeName("Hi");
    expect(command.key,equals("Book.ChangeName"));
    expect(book.name, equals("Hi"));

    command.undo();
    expect(book.name, equals("Hello"));

    command.execute();
    expect(book.name, equals("Hi"));
  });
}
