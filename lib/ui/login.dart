import 'package:checklist/ui/strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'templates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatelessWidget{
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 80.0,
        width: 300.0,
        color: ThemeColors.black,
        child: OutlineButton(
          child: Text(Strings.loginGoogle,textScaleFactor: 1.8),
          onPressed: login,
          textColor: ThemeColors.primary,
          shape: StadiumBorder(),
          disabledBorderColor: ThemeColors.primary,
          highlightedBorderColor: ThemeColors.primary,
          borderSide: BorderSide(color: ThemeColors.primary, width: 5.0),
          color: ThemeColors.primary,
        ),
      ),
    );
  }

  Future login() async {
    var signin = new GoogleSignIn();
    var googleUser = await signin.signIn();
    var googleAuth = await googleUser.authentication;
    await FirebaseAuth.instance.signInWithGoogle(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    var user = await FirebaseAuth.instance.currentUser();

    Firestore.instance.collection("users").document(user.uid).setData({
        "email": user.email,
        "displayName": user.displayName,
      },
      merge: true,
    );
  }
}