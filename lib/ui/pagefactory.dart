import 'package:checklist/ui/editalternatives.dart';
import 'package:checklist/ui/editbook.dart';
import 'package:checklist/ui/editbookbranch.dart';
import 'package:checklist/ui/edititems.dart';
import 'package:checklist/ui/landing.dart';
import 'package:checklist/ui/newbook.dart';
import 'package:checklist/ui/editlist.dart';
import 'package:checklist/ui/edititem.dart';
import 'package:checklist/ui/editnotes.dart';
import 'package:checklist/ui/editnote.dart';
import 'package:checklist/ui/usebook.dart';
import 'package:checklist/ui/login.dart';
import 'package:flutter/material.dart';

Widget LandingPage(String path, Function themeCallback) => Landing(path, themeCallback);
Widget UseBookPage(String path) => UseBook(path);
Widget EditBookPage(String path) => EditBook(path);
Widget NewBookPage(String path) => NewBook(path);
Widget EditBookBranchPage(String path) => EditBookBranch(path);
Widget EditListPage(String path) => EditList(path);
Widget EditAlternativesPage(String path) => EditAlternatives(path);
Widget EditItemsPage(String path) => EditItems(path);
Widget EditItemPage(String path) => EditItem(path);
Widget EditNotesPage(String path) => EditNotes(path);
Widget EditNotePage(String path) => EditNote(path);
Widget LoginPage() => Login();

