import 'dart:async';

import 'package:test/test.dart';
import 'package:checklist/src/randomid.dart';

main() {
  test("Generate a random ID", () {
    var id = RandomId.generate();
    expect(id, isNotNull);
    expect(id.length, greaterThan(0));
  });

  test("IDs are time-sequential with a resolution of 1 second", () async {
    var id1 = RandomId.generate();
    await new Future.delayed(const Duration(milliseconds: 1050));
    var id2 = RandomId.generate();
    expect(id2.compareTo(id1), equals(1));
    print(
        "IDs generated from test 'IDs are time-sequential with a resolution of 1 second':\n  id1: $id1, id2: $id2");
  });
}
