import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:checklist/src/book.dart';
import 'package:checklist/src/diskwriter.dart';
import 'package:checklist/src/serializer.dart';
import 'package:meta/meta.dart';

class BookIo {
  BookIo({@required this.writer});

  Map<String, String> files;
  DiskWriter writer;

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
    Map<String,Object> filesRaw = json.decode(contents);
    var filesFinal = new Map<String,String>();
    for (var key in filesRaw.keys){
      filesFinal[key] = filesRaw[key].toString();
    }
    return filesFinal;
  }

  Future initializeFileList() async {
    if (files != null) return;

    File fileList = await writer.getLocalFile("books");

    if (await fileList.exists()) {
      try {
        files = await _readFileList(fileList);
      } catch (ex){
        files = new Map<String, String>();
      }
    } else {
      files = new Map<String, String>();
    }
  }

  Future _persistFileList() async {
    var file = await writer.getLocalFile("books");
    var contents = json.encode(files);
    await file.writeAsString(contents,flush: true);
  }
}
