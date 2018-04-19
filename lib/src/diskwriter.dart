import 'dart:async';
import 'dart:io';

abstract class DiskWriter{
  Future<File> getLocalFile(String fileName);
}

class MockDiskWriter extends DiskWriter{
  Future<File> getLocalFile(String fileName) async {
    return new File("$fileName.json");
  }
}
