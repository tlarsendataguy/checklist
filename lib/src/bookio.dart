import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/serializer.dart';
import 'package:path_provider/path_provider.dart';

class BookIo {
  Map<String, String> files;
  DiskWriter writer;

  BookIo({this.writer}){
   if (writer == null) writer = new MobileDiskWriter();
  }

  Future<bool> persistBook(Book book) async {
    await initializeFileList();
    var serializedBook = Serializer.serialize(book);
    try {
      var file = await writer.getLocalFile(book.id);
      await file.writeAsString(serializedBook,flush: true);
      files[book.id] = book.name;
      await _persistFileList();
      return true;
    } catch (ex) {
      return false;
    }
  }

  Future<Book> readBook(String id) async {
    var file = await writer.getLocalFile(id);
    var contents = await file.readAsString();
    return Serializer.deserialize(contents);
  }

  Future deleteBook(String id) async {
    await initializeFileList();
    var file = await writer.getLocalFile(id);
    await file.delete();
    files.remove(id);
    await _persistFileList();
  }

  Future<Map<String, String>> _readFileList(File fileList) async {
    var contents = await fileList.readAsString();
    Map<String,String> files = JSON.decode(contents);
    return files;
  }

  Future initializeFileList() async {
    if (files != null) return;

    File fileList = await writer.getLocalFile("books");

    if (await fileList.exists()) {
      try {
        files = await _readFileList(fileList);
      } catch (ex){
        files = new Map<String,String>();
      }
    } else {
      files = new Map<String, String>();
    }
  }

  Future _persistFileList() async {
    var file = await writer.getLocalFile("books");
    var contents = JSON.encode(files);
    await file.writeAsString(contents,flush: true);
  }
}

abstract class DiskWriter{
  Future<File> getLocalFile(String fileName);
}

class MobileDiskWriter extends DiskWriter{
  Future<File> getLocalFile(String fileName) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File("$dir/$fileName.json");
  }
}

class MockDiskWriter extends DiskWriter{
  Future<File> getLocalFile(String fileName) async {
    return new File("$fileName.json");
  }
}