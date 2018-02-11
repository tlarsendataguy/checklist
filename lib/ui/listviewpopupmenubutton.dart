import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:checklist/ui/strings.dart';

typedef void PopupAction();

class ListViewPopupMenuButton extends StatefulWidget {
  final Widget child;
  final PopupAction editAction;
  final PopupAction deleteAction;

  ListViewPopupMenuButton(
      {@required this.child,
      @required this.editAction,
      @required this.deleteAction})
      : assert(child != null && editAction != null && deleteAction != null);

  createState() => new ListViewPopupMenuButtonState();
}

class ListViewPopupMenuButtonState extends State<ListViewPopupMenuButton> {
  bool isSelected = false;

  Widget build(BuildContext context) {
    return new PopupMenuButton<String>(
      onCanceled: () => setState(() => isSelected = false),
      onSelected: (String selection) async {
        switch (selection) {
          case "Edit":
            setState(() => isSelected = false);
            widget.editAction();
            break;
          case "Delete":
            var result = await showDialog<bool>(
              context: context,
              child: new AlertDialog(
                title: new Text(Strings.deleteTitle),
                content: new Text(Strings.deleteContent),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text(Strings.cancel),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  new RaisedButton(
                    child: new Text(Strings.deleteTitle),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            );
            setState(() => isSelected = false);
            if (result) widget.deleteAction();
            break;
          default:
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        setState(() => isSelected = true);
        return [
          const PopupMenuItem(
            height: 60.0,
            value: "Edit",
            child: const Center(
              child: const Icon(Icons.edit),
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            height: 60.0,
            value: "Delete",
            child: const Center(
              child: const Icon(Icons.delete),
            ),
          ),
        ];
      },
      child: new Container(
        color: isSelected ? Theme.of(context).accentColor : null,
        child: widget.child,
      ),
    );
  }
}
