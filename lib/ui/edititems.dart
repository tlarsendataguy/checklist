import 'dart:async';

import 'package:checklist/src/item.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:checklist/ui/editorpage.dart';
import 'package:checklist/ui/strings.dart';
import 'package:commandlist/commandlist.dart';
import 'package:draggablelistview/draggablelistview.dart';
import 'package:flutter/material.dart';
import 'package:checklist/ui/templates.dart';
import 'package:checklist/ui/listviewpageframe.dart';

class EditItems extends EditorPage {
  EditItems(String path)
      : super(
          title: _getTitle(path),
          path: path,
        );

  static String _getTitle(String path) {
    var result = ParsePath.validate(path);
    switch (result) {
      case ParseResult.Items:
        return Strings.editItems;
      case ParseResult.TrueBranch:
        return Strings.editTrueBranch;
      case ParseResult.FalseBranch:
        return Strings.editFalseBranch;
      default:
        return '';
    }
  }

  State<StatefulWidget> createState() => new _EditItemsState();
}

class _EditItemsState extends EditorPageState {
  CommandList<Item> _items;
  var _toCheckController = new TextEditingController();
  var _actionController = new TextEditingController();
  InputDecoration _toCheckDecoration;
  InputDecoration _actionDecoration;

  void afterParseInit() {
    _toCheckDecoration = _defaultToCheckDecoration();
    _actionDecoration = new InputDecoration(hintText: Strings.actionHint);
    switch (parseResult.result) {
      case ParseResult.Items:
        _items = parseResult.list;
        break;
      case ParseResult.TrueBranch:
        _items = parseResult.item.trueBranch;
        break;
      case ParseResult.FalseBranch:
        _items = parseResult.item.falseBranch;
        break;
      default:
        break;
    }
  }

  InputDecoration _defaultToCheckDecoration() {
    return new InputDecoration(
      hintText: Strings.toCheckHint,
    );
  }

  InputDecoration _noToCheck() {
    return new InputDecoration(
      hintText: Strings.toCheckHint,
      errorText: Strings.toCheckError,
    );
  }

  InputDecoration _errorSaving() {
    return new InputDecoration(
      hintText: Strings.toCheckHint,
      errorText: Strings.createItemError,
    );
  }

  Future _addItem() async {
    if (_toCheckController.text == '') {
      setState(_displayNoToCheck);
      return;
    }

    var toCheck = _toCheckController.text;
    var action = _actionController.text;
    var item = new Item(toCheck: toCheck, action: action);
    var command = _items.insert(item);
    var success = await io.persistBook(book);
    if (success) {
      setState(_resetEntry);
    } else {
      command.undo();
      setState(_displayErrorSaving);
    }
  }

  void _displayNoToCheck() {
    _toCheckDecoration = _noToCheck();
  }

  void _resetEntry() {
    _toCheckDecoration = _defaultToCheckDecoration();
    _toCheckController.text = '';
    _actionController.text = '';
  }

  void _displayErrorSaving() {
    _toCheckDecoration = _errorSaving();
  }

  Widget _buildRow(Item item) {
    return themeFlatButton(
        onPressed: _editItem(item),
        child: ListItem2TextRows(
          line1: item.toCheck,
          line2: item.action,
        ));
  }

  Function _editItem(Item item) {
    int index = _items.indexOf(item);
    return navigateTo("${widget.path}/$index");
  }

  Widget _buildBody() {
    return ListViewPageFrame(
      listContent: DraggableListView<Item>(
        rowHeight: 72.0,
        source: _items,
        builder: _buildRow,
        onMove: buildOnMove(_items),
      ),
      bottomContent: Column(
        children: <Widget>[
          TextField(
            controller: _toCheckController,
            decoration: _toCheckDecoration,
            maxLength: maxToCheckLen,
          ),
          Padding(
            padding: EdgeInsets.only(top: defaultPad),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _actionController,
                    decoration: _actionDecoration,
                    onSubmitted: (_) => _addItem(),
                    maxLength: maxActionLen,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addItem,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildEditorPage(_buildBody);
  }
}
