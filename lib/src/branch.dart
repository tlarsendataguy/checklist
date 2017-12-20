import 'package:checklist/src/commandList.dart';
import 'package:checklist/src/command.dart';

class Branches extends CommandList<Branch>{}

class Branch{
  int _lenTrue;
  int _lenFalse;

  get lenTrue => _lenTrue;
  get lenFalse => _lenFalse;

  Branch({int lenTrue,int lenFalse}){
    _lenTrue = lenTrue;
    _lenFalse = lenFalse;
  }

  incrementTrue(){
    return new Command(new IncrementTrue(this));
  }

  decrementTrue(){
    return new Command(new DecrementTrue(this));
  }

  incrementFalse(){
    return new Command(new IncrementFalse(this));
  }

  decrementFalse(){
    return new Command(new DecrementFalse(this));
  }
}

class IncrementTrue extends CommandAction{
  final Branch branch;
  String get key => 'Branch.IncrementTrue';

  IncrementTrue(this.branch);

  action(){
    branch._lenTrue++;
  }

  undoAction(){
    branch._lenTrue--;
  }
}

class DecrementTrue extends CommandAction{
  final Branch branch;
  String get key => 'Branch.DecrementTrue';

  DecrementTrue(this.branch);

  action(){
    if (branch.lenTrue <= 0) throw new UnsupportedError("The True branch path cannot be decremented below 0");
    branch._lenTrue--;
  }

  undoAction(){
    branch._lenTrue++;
  }
}

class IncrementFalse extends CommandAction{
  final Branch branch;
  String get key => 'Branch.IncrementFalse';

  IncrementFalse(this.branch);

  action(){
    branch._lenFalse++;
  }

  undoAction(){
    branch._lenFalse--;
  }
}

class DecrementFalse extends CommandAction{
  final Branch branch;
  String get key => 'Branch.DecrementFalse';

  DecrementFalse(this.branch);

  action(){
    if (branch.lenFalse <= 0) throw new UnsupportedError("The False branch path cannot be decremented below 0");
    branch._lenFalse--;
  }

  undoAction(){
    branch._lenFalse++;
  }
}