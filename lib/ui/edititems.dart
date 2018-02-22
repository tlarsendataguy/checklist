import 'package:checklist/src/item.dart';
import 'package:checklist/ui/editorpage.dart';
import 'package:checklist/ui/listviewpopupmenubutton.dart';
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

  initState() {
    super.initState();
    initEditorState((result) {
      _items = result.list;
    });
  }

  Widget _buildBody(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Expanded(
          child: new DraggableListView<Item>(
            rowHeight: 72.0,
            source: _items,
            builder: _buildRow,
            onMove: buildOnMove(_items),
          ),
        ),
        new Row(
          children: <Widget>[
            new Expanded(
    child: new Column(
              children: <Widget>[
                new TextField(),
                new TextField(),
              ],
            ),
    ),
            new IconButton(
                icon: new Icon(Icons.add),
              onPressed: null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(Item item) {
    return new ListViewPopupMenuButton(
      editAction: _editItem(item),
      deleteAction: _deleteItem(item),
      child: new Column(
        children: <Widget>[
          overflowText(item.toCheck),
          overflowText(item.action),
        ],
      ),
    );
  }

  Function _editItem(Item item) {
    int index = _items.indexOf(item);
    return () {
      Navigator.of(context).pushNamed("${widget.path}/$index");
    };
  }

  Function _deleteItem(Item item) {
    return () {
      var command = _items.remove(item);
      setState(() {});
      persistBookOrUndo(command);
    };
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
