import 'package:checklist/src/checklist.dart';
import 'package:checklist/ui/editorpage.dart';
import 'package:checklist/ui/templates.dart';
import 'package:draggablelistview/draggablelistview.dart';
import 'package:checklist/ui/listviewpopupmenubutton.dart';
import 'package:checklist/ui/strings.dart';
import 'package:commandlist/commandlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:checklist/ui/listviewpageframe.dart';

class EditBookBranch extends EditorPage {
  EditBookBranch(String path)
      : super(
            title: _getTitle(path), path: path);

  static String _getTitle(String path) {
    var result = ParsePath.validate(path);
    if (result == ParseResult.EmergencyLists) {
      return Strings.editEmergencyLists;
    } else {
      return Strings.editNormalLists;
    }
  }

  createState() => new _EditBookBranchState();
}

class _EditBookBranchState extends EditorPageState {
  TextEditingController _listNameController;
  InputDecoration _listNameDecoration;
  CommandList<Checklist> _lists;

  void afterParseInit() {
    _listNameDecoration = _defaultListNameDecoration();
    _listNameController = new TextEditingController();

    switch (parseResult.result) {
      case ParseResult.NormalLists:
        _lists = book.normalLists;
        break;
      case ParseResult.EmergencyLists:
        _lists = book.emergencyLists;
        break;
      default:
        break;
    }
  }

  Widget build(BuildContext context) {
    return buildEditorPage(_buildBody);
  }

  Widget _buildBody() {
    return ListViewPageFrame(
      listContent: DraggableListView<Checklist>(
        rowHeight: 48.0,
        source: _lists,
        builder: _checklistToWidget,
        onMove: buildOnMove(_lists),
      ),
      bottomContent: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              onSubmitted: _createChecklist,
              controller: _listNameController,
              decoration: _listNameDecoration,
              maxLength: maxNameLen,
            ),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _pressCreate,
          ),
        ],
      ),
    );
  }

  InputDecoration _defaultListNameDecoration() {
    return new InputDecoration(hintText: Strings.nameHint);
  }

  void _createChecklist(String listName) {
    if (listName == '') {
      setState(_noNameProvided);
      return;
    }

    var list = new Checklist(name: listName);
    var command = _lists.insert(list);
    io.persistBook(book).then((bool result) {
      setState(() {
        if (result) {
          _resetTextfield();
        } else {
          command.undo();
          _errorCreating();
        }
      });
    });
  }

  _noNameProvided() {
    _listNameDecoration = new InputDecoration(
      hintText: Strings.nameHint,
      errorText: Strings.noNameError,
    );
  }

  _resetTextfield() {
    _listNameDecoration = new InputDecoration(
      hintText: Strings.nameHint,
    );
    _listNameController.text = "";
  }

  _errorCreating() {
    _listNameDecoration = new InputDecoration(
      hintText: Strings.nameHint,
      errorText: Strings.createListFailed,
    );
  }

  void _pressCreate() {
    _createChecklist(_listNameController.text);
  }

  Widget _checklistToWidget(Checklist list) {
    var editPath = widget.path + "/" + list.id;

    return new ListViewPopupMenuButton(
      editAction: navigateTo(editPath),
      deleteAction: () async {
        var command = _lists.remove(list);
        var success = await io.persistBook(book);
        if (!success)
          command.undo();
        else
          setState(() {});
      },
      child: ListItem1TextRow(list.name),
    );
  }
}
