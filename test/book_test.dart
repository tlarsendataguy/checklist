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

  test("Change book name", () {
    var book = new Book(name: "Hello");
    expect(book.name, equals("Hello"));

    var command = book.changeName("Hi");
    expect(command.key, equals("Book.ChangeName"));
    expect(book.name, equals("Hi"));

    command.undo();
    expect(book.name, equals("Hello"));

    command.execute();
    expect(book.name, equals("Hi"));
  });

  test("Deleting a book removes it from all alternatives", () {
    var book = new Book(name: "Book");
    var list1 = new Checklist(name: "List 1");
    var list2 = new Checklist(name: "List 2");
    var list3 = new Checklist(name: "List 3");

    list1.setNextPrimary(list3);
    list2.nextAlternatives.insert(list3);

    book.normalLists.insert(list1);
    book.normalLists.insert(list2);
    book.normalLists.insert(list3);

    expect(list1.nextPrimary.name, equals("List 3"));
    expect(list2.nextAlternatives[0].name, equals("List 3"));

    var command = book.normalLists.remove(list3);

    expect(list1.nextPrimary, isNull);
    expect(list2.nextAlternatives.length, equals(0));

    command.undo();

    expect(list1.nextPrimary.name, equals("List 3"));
    expect(list2.nextAlternatives[0].name, equals("List 3"));
  });

  test("Delete a book with duplicate next alternatives", () {
    var book = new Book(name: "Book");
    var list1 = new Checklist(name: "List 1");
    var list2 = new Checklist(name: "List 2");
    var list3 = new Checklist(name: "List 3");

    book.normalLists.insert(list1);
    book.normalLists.insert(list2);
    book.normalLists.insert(list3);
    list1.nextAlternatives.insert(list2);
    list1.nextAlternatives.insert(list3);
    list1.nextAlternatives.insert(list2);

    expect(list1.nextAlternatives.length, equals(3));
    expect(list1.nextAlternatives[0].name, equals("List 2"));
    expect(list1.nextAlternatives[1].name, equals("List 3"));
    expect(list1.nextAlternatives[2].name, equals("List 2"));

    var command = book.normalLists.remove(list2);
    expect(list1.nextAlternatives[0].name, equals("List 3"));
    expect(list1.nextAlternatives.length, equals(1));

    command.undo();
    expect(list1.nextAlternatives.length, equals(3));
    expect(list1.nextAlternatives[0].name, equals("List 2"));
    expect(list1.nextAlternatives[1].name, equals("List 3"));
    expect(list1.nextAlternatives[2].name, equals("List 2"));

    command.execute();
    expect(list1.nextAlternatives[0].name, equals("List 3"));
    expect(list1.nextAlternatives.length, equals(1));
  });

  test("Delete an alternative in a different collection",(){
    var book = new Book(name: "Book");
    var list1 = new Checklist(name: "List 1");
    var list2 = new Checklist(name: "List 2");

    book.normalLists.insert(list1);
    book.emergencyLists.insert(list2);
    list1.setNextPrimary(list2);

    expect(list1.nextPrimary.name, equals("List 2"));

    var command = book.emergencyLists.remove(list2);
    expect(list1.nextPrimary, isNull);

    command.undo();
    expect(list1.nextPrimary.name, equals("List 2"));

    command.execute();
    expect(list1.nextPrimary, isNull);
  });
}
