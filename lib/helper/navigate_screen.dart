import 'package:flutter/material.dart';
import 'package:twithub/models/post.dart';
import 'package:twithub/screen/home_screen.dart';
import 'package:twithub/screen/post_screen.dart';
import 'package:twithub/screen/profile_screen.dart';

import '../screen/account_settings_screen.dart';
import '../screen/blocked_user_screen.dart';

// go to user page
void goUserPage(BuildContext context, String uid) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ProfileScreen(uid: uid)),
  );
}

// go to post page
void goPostPage(BuildContext context, Post post) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PostScreen(post: post)),
  );
}

// go to blocked user page
void goBlockPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => BlockedUserScreen()),
  );
}

// go to account settings page
void goAccountSettingsPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => AccountSettingsScreen()),
  );
}

//go to home page (remove all previous routes,this is good for reload)
void goHomePage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => HomeScreen()),
  );
}
