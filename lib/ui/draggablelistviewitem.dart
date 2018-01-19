import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

typedef void MoveItemCallback(int oldIndex);
typedef void StartDragCallback();
typedef void StopDragCallback();

class DraggableListViewItem extends StatefulWidget {
  final int index;
  final Widget child;
  final MoveItemCallback moveItem;
  final StartDragCallback startDrag;
  final StopDragCallback stopDrag;

  DraggableListViewItem({
    @required this.index,
    @required this.child,
    @required this.moveItem,
    this.startDrag,
    this.stopDrag,
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
        startTarget();
        return true;
      },
      onAccept: (oldIndex) {
        stopTarget();
        if (widget.moveItem != null) widget.moveItem(oldIndex);
      },
      onLeave: (_) => stopTarget(),
      builder: buildRow,
    );
  }

  Widget buildRow(BuildContext context, List<int> data, List<Object> _) {
    if (isDragging)
      return const Text("");
    else
      return new AnimatedPadding(
        padding: new EdgeInsets.fromLTRB(
            0.0,
            isTarget ? 50.0 : 0.0,
            0.0,
          0.0,
        ),
        child: new Row(
          children: <Widget>[
            new Draggable<int>(
              data: widget.index,
              maxSimultaneousDrags: 1,
              childWhenDragging: const Text(""),
              onDragStarted: startDragging,
              onDragCompleted: stopDragging,
              onDraggableCanceled: (Velocity velocity, Offset offset) {
                stopDragging();
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

  void startDragging() {
    setState(() => isDragging = true);
    if (widget.startDrag != null) widget.startDrag();
  }

  void stopDragging() {
    setState(() => isDragging = false);
    if (widget.stopDrag != null) widget.stopDrag();
  }

  void startTarget() {
    setState(() => isTarget = true);
  }

  void stopTarget() {
    setState(() => isTarget = false);
  }
}
