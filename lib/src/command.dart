class Command{
  bool _canUndo;
  bool _canRedo;
  final CommandAction actions;

  get canUndo => _canUndo;
  get canRedo => _canRedo;
  get key => actions.key;

  Command(this.actions){
    _canUndo = true;
    _canRedo = false;
    actions.action();
  }

  void redo(){
    if (!_canRedo) throw new StateError(
        "redo cannot be performed because canRedo is false",
    );

    _canUndo = true;
    _canRedo = false;
    actions.action();
  }

  void undo(){
    if (!_canUndo) throw new StateError(
      "undo cannot be performed because canUndo is false",
    );

    _canUndo = false;
    _canRedo = true;
    actions.undoAction();
  }
}

abstract class CommandAction{
  String get key;
  void action();
  void undoAction();
}
