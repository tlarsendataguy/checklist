import 'package:checklist/ui/draggablelistviewitem.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

enum DragHandleLocation { left, right }

class DraggableListView extends StatefulWidget {
  final IndexedWidgetBuilder builder;
  final int childCount;
  final DragHandleLocation handleLocation;

  DraggableListView(this.builder,
      {@required this.childCount,
      this.handleLocation = DragHandleLocation.left});

  createState() => new DraggableListViewState();
}

class DraggableListViewState extends State<DraggableListView> {
  bool isDragging = false;
  final ScrollController scroller = new ScrollController();

  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        _dragScrollArea(up: true),
        new Expanded(
          child: new CustomScrollView(
            controller: scroller,
            slivers: [
              new SliverList(
                delegate: new SliverChildBuilderDelegate(
                  _buildChild,
                  childCount: widget.childCount,
                ),
              ),
            ],
          ),
        ),
        _dragScrollArea(up: false),
      ],
    );
  }

  Widget _buildChild(BuildContext context, int index) {
    //return new Text("Index: $index");
    return new DraggableListViewItem(
      moveItem: null,
      index: index,
      child: widget.builder(context, index),
      startDrag: _startDrag,
      stopDrag: _stopDrag,
    );
  }

  Widget _dragScrollArea({bool up}) {
    var height = isDragging ? 30.0 : 0.0;
    var icon = new Icon(up ? Icons.arrow_drop_up : Icons.arrow_drop_down);
    return new AnimatedContainer(
      duration: new Duration(milliseconds: 100),
      height: height,
      color: Theme.of(context).highlightColor,
      child: isDragging ? icon : null,
      constraints: new BoxConstraints.expand(height: height),
    );
  }

  void _startDrag(){
    setState(() => isDragging = true);
  }

  void _stopDrag(){
    setState(() => isDragging = false);
  }
}
