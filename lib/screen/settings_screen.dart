import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twithub/components/my_setting_tile.dart';
import 'package:twithub/helper/navigate_screen.dart';
import 'package:twithub/provider/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'S E T T I N G S',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Theme Dark & light mode
          MySettingTile(
            title: 'Dark Mode',
            action: CupertinoSwitch(
              value: Provider.of<ThemeProvider>(
                context,
                listen: false,
              ).isDarkMode,
              onChanged: (value) => Provider.of<ThemeProvider>(
                context,
                listen: false,
              ).toggleTheme(),
            ),
          ),
          // Blocked user
          MySettingTile(
            title: 'Blocked user',
            action: IconButton(
              onPressed: () => goBlockPage(context),
              icon: Icon(
                Icons.arrow_forward_rounded,
                size: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          // Account setting
          MySettingTile(
            title: 'Account Settings',
            action: IconButton(
              onPressed: () => goAccountSettingsPage(context),
              icon: Icon(
                Icons.arrow_forward_rounded,
                size: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
