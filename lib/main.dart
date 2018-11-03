import 'package:checklist/ui/pathroute.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:checklist/ui/templates.dart';
import 'package:checklist/ui/strings.dart';

import 'package:checklist/src/mobilediskwriter.dart';
import 'package:checklist/src/parsepath.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:checklist/ui/pagefactory.dart';

typedef MaterialPageRoute RouteBuilder(Widget builder);

void main() {
  ParsePath.setWriter(new MobileDiskWriter());
  var signin = new GoogleSignIn();
  signin.signInSilently().then((account) async {
    if (account != null){
      var auth = await account.authentication;
      FirebaseAuth.instance.signInWithGoogle(idToken: auth.idToken, accessToken: auth.accessToken);
    }
  });
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: Strings.appTitle,
      theme: ThemeColors.theme,
      onGenerateRoute: _getRoute,
    );
  }

  Route _getRoute(RouteSettings settings) {
    var path = settings.name;
    var result = ParsePath.validate(path);
    var router = _buildRouter(settings);

    switch (result) {
      case ParseResult.Home:
        return router(LandingPage(path, changeTheme));
      case ParseResult.NewBook:
        return router(NewBookPage(path));
      case ParseResult.UseBook:
        return router(UseBookPage(path));
      case ParseResult.Book:
        return router(EditBookPage(path));
      case ParseResult.NormalLists:
      case ParseResult.EmergencyLists:
        return router(EditBookBranchPage(path));
      case ParseResult.List:
        return router(EditListPage(path));
      case ParseResult.Alternatives:
        return router(EditAlternativesPage(path));
      case ParseResult.Items:
      case ParseResult.TrueBranch:
      case ParseResult.FalseBranch:
        return router(EditItemsPage(path));
      case ParseResult.Item:
        return router(EditItemPage(path));
      case ParseResult.Notes:
        return router(EditNotesPage(path));
      case ParseResult.Note:
        return router(EditNotePage(path));
      default:
        return null;
    }
  }

  RouteBuilder _buildRouter(RouteSettings settings) {
    int level;
    String path = settings.name;

    if (path == '/')
      level = 0;
    else
      level = path.split('/').length - 1;

    return (Widget builder) {
      return PathRoute(
        settings: settings,
        level: level,
        builder: (context) => StreamBuilder<FirebaseUser>(
              stream: FirebaseAuth.instance.onAuthStateChanged,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CupertinoActivityIndicator();
                } else if (snapshot.hasData) {
                  return builder;
                } else {
                  return LoginPage();
                }
              },
            ),
      );
    };
  }

  void changeTheme() {
    setState(ThemeColors.toggleTheme);
  }
}
