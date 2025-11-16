/*

Auth Get
this is to check if the user is logged in or not.

------------------------------------------------------------------------------

if user is logged in -> go to home screen.
if user is not logged in -> go to login & register screen.

*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twithub/screen/home_screen.dart';
import 'package:twithub/services/auth/login_or_register.dart';

class AuthGet extends StatelessWidget {
  const AuthGet({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomeScreen();
        } else {
          return LoginOrRegister();
        }
      },
    );
  }
}
