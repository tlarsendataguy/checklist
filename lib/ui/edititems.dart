import 'package:checklist/src/item.dart';
import 'package:checklist/ui/editorpage.dart';
import 'package:checklist/ui/strings.dart';
import 'package:commandlist/commandlist.dart';
import 'package:draggablelistview/draggablelistview.dart';
import 'package:flutter/material.dart';
import 'package:checklist/ui/templates.dart';

class EditItems extends EditorPage {
  EditItems(String path, ThemeChangeCallback onThemeChanged)
      : super(path, onThemeChanged, defaultPadding);

  State<StatefulWidget> createState() => new EditItemsState();
}

class EditItemsState extends EditorPageState {
  EditItemsState();

  CommandList<Item> _items;

  initState(){
    super.initState();
    initEditorState((result){
      _items = result.list;
    });
  }

  Widget _buildBody(BuildContext context){
    return new DraggableListView<Item>(
      rowHeight: 72.0,
      source: _items,
      builder: _buildRow,
      onMove: buildOnMove(_items),
    );
  }

  Widget _buildRow(Item item){
    return new Column(
      children: <Widget>[
        overflowText(item.toCheck),
        overflowText(item.action),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildPage(
      context: context,
      title: Strings.editItems,
      bodyBuilder: _buildBody,
    );
  }
}
