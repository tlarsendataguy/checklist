import 'dart:async';
import 'dart:io';

import 'package:checklist/src/diskwriter.dart';
import 'package:path_provider/path_provider.dart';

class MobileDiskWriter extends DiskWriter{
  Future<File> getLocalFile(String fileName) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File("$dir/$fileName.json");
  }
}
