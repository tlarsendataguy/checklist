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

  void afterParseInit() {
    _item = parseResult.item;
    _toCheckController = new TextEditingController(text: _item.toCheck);
    _actionController = new TextEditingController(text: _item.action);
  }

  Widget _buildBody() {
    return new Padding(
      padding: defaultLTRB,
      child: new ListView(
        children: <Widget>[
          new TextField(
            controller: _toCheckController,
          ),
          new TextField(
            controller: _actionController,
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return buildEditorPage(_buildBody);
  }
}
