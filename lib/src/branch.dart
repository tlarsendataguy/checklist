import 'package:checklist/src/commandList.dart';

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
}