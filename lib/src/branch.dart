import 'package:checklist/src/commandList.dart';

class Branches extends CommandList<Branch>{}

class Branch{
  int _at;
  int _lenTrue;
  int _lenFalse;

  get at => _at;
  get lenTrue => _lenTrue;
  get lenFalse => _lenFalse;

  Branch({int at,int lenTrue,int lenFalse}){
    _at = at;
    _lenTrue = lenTrue;
    _lenFalse = lenFalse;
  }
}