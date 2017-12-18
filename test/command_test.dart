import 'package:test/test.dart';
import 'package:checklist/src/command.dart';

main() {
  test("Undo and redo work correctly", () {
    var command = new Command(new CommandActionTester());
    expect(command.canUndo, equals(true));
    expect(command.canRedo, equals(false));

    command.undo();
    expect(command.canUndo, false);
    expect(command.canRedo, true);

    command.redo();
    expect(command.canUndo, true);
    expect(command.canRedo, false);
  });

  test("Performing redo when unable to redo throws an error", () {
    var command = new Command(new CommandActionTester());
    expect(
        () => command.redo(),
        throwsA(new isInstanceOf<StateError>()),
    );
  });

  test("Performing undo when unable to undo throws an error", () {
    var command = new Command(new CommandActionTester());
    command.undo();
    expect(
          () => command.undo(),
      throwsA(new isInstanceOf<StateError>()),
    );
  });
}

class CommandActionTester extends CommandAction {
  void action() {}
  void undoAction() {}
}
