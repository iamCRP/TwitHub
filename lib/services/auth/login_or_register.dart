import 'package:flutter/material.dart';
import 'package:twithub/screen/login_screen.dart';
import 'package:twithub/screen/register_screen.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool showLogin = true;

  void toggleScreen() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLogin) {
      return LoginScreen(onTap: toggleScreen);
    } else {
      return RegisterScreen(onTap: toggleScreen);
    }
  }
}
