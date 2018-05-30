import 'package:checklist/src/note.dart';

class Strings{
  static String appTitle = "Checklist App";
  static String newBookTitle = "New book";
  static String newBookButton = "Create new book";
  static String editBookTitle = "Edit book";
  static String normalLists = "Normal";
  static String emergencyLists = "Emergency";
  static String editNormalLists = "Edit normal checklists";
  static String editEmergencyLists = "Edit emergency checklists";
  static String editLists(String type) => "Edit $type checklists";
  static String editList = "Edit checklist";
  static String nameHint = "Name";
  static String noNameError = "Name cannot be blank";
  static String toCheckHint = "Parameter to check";
  static String toCheckError = "The parameter cannot be blank";
  static String createItemError = "There was an error saving the new item.  Please try again.";
  static String actionHint = "Value to verify (optional)";
  static String createList = "Add checklist";
  static String createListFailed = "List could not be created";
  static String editItems = "Edit items";
  static String editNextAlternatives = "Edit alternatives";
  static String editNextPrimary = "Which checklist should be loaded after this checklist is finished?";
  static String noSelection = "<No selection>";
  static String deleteTitle = "Delete";
  static String deleteContent = "Are you sure you want to delete the selected item?";
  static String cancel = "Cancel";
  static String addAlternative = 'Add alternative';
  static String editItem = "Edit item";
  static String editTrueBranch = "Edit true items";
  static String editFalseBranch = "Edit false items";
  static String addNote = "Add note";
  static String editNotes = "Edit notes";
  static String priorityToString(Priority priority){
    switch (priority){
      case Priority.Caution:
        return "Caution";
      case Priority.Warning:
        return "Warning";
      case Priority.Note:
        return "Note";
      default:
        return "";
    }
  }
  static String existingNotes = "Notes already in the checklist:";
  static String createNote = "Create a new note:";
  static String noNoteTextError = "The note cannot be blank";
  static String editNote = "Edit note";
  static String yes = "Yes";
  static String no = "No";
  static String exit = "Exit";
  static String restart = "Restart";
  static String completed = "Checklist completed";
  static String next = "Next checklist:";
  static String alternatives = "Alternatives:";
  static String tapToClose = "Tap to close";
}