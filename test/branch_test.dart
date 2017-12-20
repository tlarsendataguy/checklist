import 'package:checklist/src/branch.dart';
import 'package:test/test.dart';

main(){
  test("Increment true branch",(){
    var branch = new Branch(lenTrue: 0,lenFalse: 0);

    var command = branch.incrementTrue();
    expect(branch.lenTrue,equals(1));

    command.undo();
    expect(branch.lenTrue,equals(0));

    command.redo();
    expect(branch.lenTrue,equals(1));
  });

  test("Decrement true branch",(){
    var branch = new Branch(lenTrue: 1, lenFalse: 0);

    var command = branch.decrementTrue();
    expect(branch.lenTrue,equals(0));

    command.undo();
    expect(branch.lenTrue, equals(1));

    command.redo();
    expect(branch.lenTrue, equals(0));
  });

  test("Decrement true below zero",(){
    var branch = new Branch(lenTrue: 0, lenFalse: 0);

    expect(()=>branch.decrementTrue(),throwsA(new isInstanceOf<UnsupportedError>()));
  });

  test("Increment false branch",(){
    var branch = new Branch(lenTrue: 0,lenFalse: 0);

    var command = branch.incrementFalse();
    expect(branch.lenFalse,equals(1));

    command.undo();
    expect(branch.lenFalse,equals(0));

    command.redo();
    expect(branch.lenFalse,equals(1));
  });

  test("Decrement false branch",(){
    var branch = new Branch(lenTrue: 0, lenFalse: 1);

    var command = branch.decrementFalse();
    expect(branch.lenFalse,equals(0));

    command.undo();
    expect(branch.lenFalse, equals(1));

    command.redo();
    expect(branch.lenFalse, equals(0));
  });

  test("Decrement false below zero",(){
    var branch = new Branch(lenTrue: 0, lenFalse: 0);

    expect(()=>branch.decrementFalse(),throwsA(new isInstanceOf<UnsupportedError>()));
  });
}