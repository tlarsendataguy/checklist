import 'package:checklist/src/item.dart';
import 'package:checklist/ui/editorpage.dart';
import 'package:checklist/ui/strings.dart';
import 'package:checklist/ui/templates.dart';
import 'package:flutter/material.dart';

class EditItem extends EditorPage {
  EditItem(String path, ThemeChangeCallback onThemeChanged)
      : super(
          title: Strings.editItem,
          path: path,
          onThemeChanged: onThemeChanged,
        );

  createState() => new _EditItemState();
}

class _EditItemState extends EditorPageState {
  Item _item;
  TextEditingController _toCheckController;
  TextEditingController _actionController;
  InputDecoration _toCheckDecoration;
  bool _showBranches;

  void afterParseInit() {
    _item = parseResult.item;
    _toCheckController = new TextEditingController(text: _item.toCheck);
    _actionController = new TextEditingController(text: _item.action);
    _toCheckDecoration = new InputDecoration();
    _setBranchVisibility();
  }

  Widget _buildBody() {
    return Padding(
      padding: pagePadding,
      child: ListView(
        children: _buildEditorItems(),
      ),
    );
  }

  List<Widget> _buildEditorItems() {
    var items = <Widget>[
      editorElementPadding(
        child: TextField(
          controller: _toCheckController,
          onSubmitted: _changeToCheck,
          decoration: _toCheckDecoration,
          maxLength: maxToCheckLen,
        ),
      ),
      editorElementPadding(
        child: TextField(
          controller: _actionController,
          onSubmitted: _changeAction,
          maxLength: maxActionLen,
        ),
      ),
      editorElementPadding(
        child: themeRaisedButton(
          child: Text(Strings.editNotes + " (${_item.notes.length})"),
          onPressed: navigateTo("${widget.path}/notes"),
        ),
      ),
    ];

    if (_showBranches) {
      items.addAll(<Widget>[
        editorElementPadding(
          child: themeRaisedButton(
            child:
                Text(Strings.editTrueBranch + " (${_item.trueBranch.length})"),
            onPressed: navigateTo("${widget.path}/true"),
          ),
        ),
        editorElementPadding(
          child: themeRaisedButton(
            child: Text(
                Strings.editFalseBranch + " (${_item.falseBranch.length})"),
            onPressed: navigateTo("${widget.path}/false"),
          ),
        ),
      ]);
    }

    return items;
  }

  void _changeToCheck(String newToCheck) {
    if (newToCheck.isEmpty) {
      _setToCheckDecoration(Strings.toCheckError);
      return;
    }

    _setToCheckDecoration("");
    var command = _item.setToCheck(newToCheck);
    persistBookOrUndo(command);
  }

  void _changeAction(String newAction) {
    var command = _item.setAction(newAction);
    setState(_setBranchVisibility);
    persistBookOrUndo(command);
  }

  void _setToCheckDecoration(String error) {
    setState(() {
      _setBranchVisibility();
      _toCheckDecoration = new InputDecoration(errorText: error);
    });
  }

  void _setBranchVisibility() {
    _showBranches = _item.action.isEmpty;
  }

  Widget build(BuildContext context) {
    return buildEditorPage(_buildBody);
  }
}
