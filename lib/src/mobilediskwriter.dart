import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:checklist/src/bookio.dart';

class MobileDiskWriter extends DiskWriter{
  Future<File> getLocalFile(String fileName) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File("$dir/$fileName.json");
  }
}
