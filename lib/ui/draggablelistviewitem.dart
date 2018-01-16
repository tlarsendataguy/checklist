import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

typedef void MoveItemCallback(int oldIndex);

class DraggableListViewItem extends StatefulWidget {
  final int index;
  final Widget child;
  final MoveItemCallback moveItem;

  DraggableListViewItem({
    @required this.index,
    @required this.child,
    @required this.moveItem,
  });

  createState() => new DraggableListViewItemState();
}

class DraggableListViewItemState extends State<DraggableListViewItem> {
  bool isTarget = false;
  bool isDragging = false;

  DraggableListViewItemState();

  build(BuildContext context) {
    return new DragTarget<int>(
      onWillAccept: (_) {
        setState(startTarget);
        return true;
      },
      onAccept: (oldIndex) {
        setState(stopTarget);
        widget.moveItem(oldIndex);
      },
      onLeave: (_)  => setState(stopTarget),
      builder: buildRow,
    );
  }

  void resetIsTarget() {
    setState(() => isTarget = false);
  }

  Widget buildRow(BuildContext context, List<int> data, List<Object> _){
    if (isDragging)
      return new Text("");
    else
      return new AnimatedPadding(
        padding:
        new EdgeInsets.fromLTRB(0.0, isTarget ? 20.0 : 0.0, 0.0, 0.0),
        child: new Row(
          children: <Widget>[
            new Draggable<int>(
              data: widget.index,
              maxSimultaneousDrags: 1,
              childWhenDragging: new Text(""),
              onDragStarted: startDragging,
              onDragCompleted: stopDragging,
              onDraggableCanceled: (Velocity velocity, Offset offset) {
                setState(stopDragging);
              },
              feedback: new Container(
                width: MediaQuery.of(context).size.width,
                child: new Card(
                  child: new Row(
                    children: <Widget>[
                      new Icon(Icons.drag_handle),
                      new Expanded(child: widget.child),
                    ],
                  ),
                ),
              ),
              child: new Icon(Icons.drag_handle),
            ),
            new Expanded(child: widget.child),
          ],
        ),
        duration: new Duration(milliseconds: 100),
      );
  }

  void startDragging() => isDragging = true;
  void stopDragging() => isDragging = false;
  void startTarget() => isTarget = true;
  void stopTarget() => isTarget = false;
}
