import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twithub/provider/database_provider.dart';
import 'package:twithub/provider/theme_provider.dart';

import 'firebase_options.dart';
import 'services/auth/auth_get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DatabaseProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'TwitHub',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeDate,
      initialRoute: '/',
      routes: {'/': (context) => AuthGet()},
    );
  }
}
