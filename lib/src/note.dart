import 'package:command/command.dart';

enum Priority {
  Note,
  Caution,
  Warning,
}

class Note implements Comparable<Note> {
  Priority _priority;
  String _text;

  Priority get priority => _priority;
  String get text => _text;

  Note(Priority priority, String text) {
    assert(priority != null && text != null);
    _priority = priority;
    _text = text;
  }

  int compareTo(Note other) {
    if (other.priority.index > this.priority.index)
      return 1;
    else if (other.priority.index < this.priority.index) return -1;

    return this.text.compareTo(other.text);
  }

  Command changeText(String newText) {
    assert(newText != null);
    return new Command(new ChangeText(this, newText))..execute();
  }

  Command changePriority(Priority newPriority) {
    assert(newPriority != null);
    return new Command(new ChangePriority(this, newPriority))..execute();
  }
}

class ChangeText extends CommandAction {
  final Note note;
  final String newText;
  final String oldText;
  String get key => "Note.ChangeText";

  ChangeText(this.note, this.newText) : oldText = note.text;

  action() {
    note._text = newText;
  }

  undoAction() {
    note._text = oldText;
  }
}

class ChangePriority extends CommandAction {
  final Note note;
  final Priority oldPriority;
  final Priority newPriority;
  String get key => "Note.ChangePriority";

  ChangePriority(this.note, this.oldPriority) : newPriority = note.priority;

  action() {
    note._priority = oldPriority;
  }

  undoAction() {
    note._priority = newPriority;
  }
}
